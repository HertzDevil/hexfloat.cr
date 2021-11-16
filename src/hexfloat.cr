# Provides conversion functions between hexadecimal floating-point literals and
# floating-point values.
module HexFloat
  VERSION = "1.0.0"

  private module Converter(F, U)
    @[AlwaysInline]
    def self.to_f(str : String) : F
      ptr = str.to_unsafe
      finish = ptr + str.bytesize

      negative = if ptr < finish && ptr.value === '-'
                   ptr += 1
                   true
                 else
                   false
                 end

      check_ch '0'
      check_ch 'x'

      mantissa = U.zero
      mantissa_max = ~(U::MAX << (F::MANT_DIGITS + 1))
      trailing_nonzero = false
      exp_shift = 0

      found_digits = false
      while ptr < finish
        case ch = ptr.value
        when 0x30..0x39
          found_digits = true
          digit = ch - 0x30
        when 0x41..0x46
          found_digits = true
          digit = ch - 0x41 + 10
        when 0x61..0x66
          found_digits = true
          digit = ch - 0x61 + 10
        else
          break
        end
        ptr += 1

        if mantissa != 0
          exp_shift += 4
        elsif digit != 0
          exp_shift = sizeof(typeof(digit)) * 8 - digit.leading_zeros_count
        end

        mix_digit
      end
      raise ArgumentError.new("empty integral part") unless found_digits

      if ptr < finish && ptr.value === '.'
        ptr += 1
        found_digits = false
        while ptr < finish
          case ch = ptr.value
          when 0x30..0x39
            found_digits = true
            digit = ch - 0x30
          when 0x41..0x46
            found_digits = true
            digit = ch - 0x41 + 10
          when 0x61..0x66
            found_digits = true
            digit = ch - 0x61 + 10
          else
            break
          end
          ptr += 1

          if mantissa == 0
            exp_shift -= 4
            if digit != 0
              exp_shift += sizeof(typeof(digit)) * 8 - digit.leading_zeros_count
            end
          end

          mix_digit
        end
        raise ArgumentError.new("empty fractional part") unless found_digits
      end

      check_ch 'p'

      exp_negative = false
      if ptr < finish
        case ptr.value
        when '+'
          ptr += 1
        when '-'
          exp_negative = true
          ptr += 1
        end
      end

      exp_add = 0
      found_digits = false
      while ptr < finish
        case ch = ptr.value
        when 0x30..0x39
          found_digits = true
          digit = ch - 0x30
        else
          break
        end
        ptr += 1

        raise ArgumentError.new("exponent overflow") if exp_add > Int32::MAX // 10
        exp_add &*= 10
        raise ArgumentError.new("exponent overflow") if exp_add > Int32::MAX - digit
        exp_add &+= digit
      end
      raise ArgumentError.new("empty exponent") unless found_digits

      {% if F == Float32 %}
        if ptr + 4 <= finish && ptr[0] === '_' && ptr[1] === 'f' && ptr[2] === '3' && ptr[3] === '2'
          ptr += 4
        elsif ptr + 3 <= finish && ptr[0] === 'f' && ptr[1] === '3' && ptr[2] === '2'
          ptr += 3
        end
      {% elsif F == Float64 %}
        if ptr + 4 <= finish && ptr[0] === '_' && ptr[1] === 'f' && ptr[2] === '6' && ptr[3] === '4'
          ptr += 4
        elsif ptr + 3 <= finish && ptr[0] === 'f' && ptr[1] === '6' && ptr[2] === '4'
          ptr += 3
        end
      {% end %}

      raise ArgumentError.new("trailing characters") unless ptr == finish

      return make_float(negative, 0, 0) if mantissa == 0

      exp_shift += F::MAX_EXP - 2
      if exp_negative
        exp_shift -= exp_add
      else
        exp_shift += exp_add
      end

      if mantissa <= (mantissa_max >> 1)
        mantissa <<= F::MANT_DIGITS - (sizeof(U) * 8 - mantissa.leading_zeros_count) + 1
      end

      if exp_shift <= 0
        trailing_nonzero ||= mantissa & ~(U::MAX << (1 - exp_shift)) != 0
        mantissa >>= 1 - exp_shift
        round_up = (mantissa & 0b1) != 0 && ((mantissa & 0b10) != 0 || trailing_nonzero)
        mantissa >>= 1
        mantissa &+= 1 if round_up
        exp_shift = mantissa > (mantissa_max >> 2) ? 1 : 0
      elsif mantissa > (mantissa_max >> 1)
        round_up = (mantissa & 0b1) != 0 && ((mantissa & 0b10) != 0 || trailing_nonzero)
        mantissa >>= 1
        mantissa &+= 1 if round_up
        exp_shift += 1 if mantissa > (mantissa_max >> 1)
      end

      return make_float(negative, 0, F::MAX_EXP * 2 - 1) if exp_shift >= F::MAX_EXP * 2 - 1

      make_float(negative, mantissa, exp_shift)
    end

    private def self.make_float(negative, mantissa, exponent) : F
      u = negative ? U.new!(1) << (sizeof(U) * 8 - 1) : U.zero
      u |= mantissa & ~(U::MAX << (F::MANT_DIGITS - 1))
      u |= U.new!(exponent) << (F::MANT_DIGITS - 1)

      u.unsafe_as(F)
    end

    private macro check_ch(ch)
      raise ArgumentError.new("expected #{ {{ ch }}.inspect }") unless ptr < finish && ptr.value === {{ ch }}
      ptr += 1
    end

    private macro mix_digit
      if mantissa > (mantissa_max >> 1)
        trailing_nonzero ||= digit != 0
      elsif mantissa > (mantissa_max >> 2)
        # 00000000 000[.... ........ ........ ........ ........ ........ .......]
        mantissa <<= 1
        mantissa |= digit >> 3
        trailing_nonzero ||= digit & 0b0111 != 0
        # 00000000 00[..... ........ ........ ........ ........ ........ ......]? ???
      elsif mantissa > (mantissa_max >> 3)
        # 00000000 0000[... ........ ........ ........ ........ ........ .......]
        mantissa <<= 2
        mantissa |= digit >> 2
        trailing_nonzero ||= digit & 0b0011 != 0
        # 00000000 00[..... ........ ........ ........ ........ ........ .....]?? ??
      elsif mantissa > (mantissa_max >> 4)
        # 00000000 00000[.. ........ ........ ........ ........ ........ .......]
        mantissa <<= 3
        mantissa |= digit >> 1
        trailing_nonzero ||= digit & 0b0001 != 0
        # 00000000 00[..... ........ ........ ........ ........ ........ ....]??? ?
      else
        mantissa <<= 4
        mantissa |= digit
      end
    end

    @[AlwaysInline]
    def self.to_s(io : IO, num : F) : Nil
      u = num.unsafe_as(U)
      negative = u & (U.new!(1) << (sizeof(U) * 8 - 1)) != 0
      exponent = ((u >> (F::MANT_DIGITS - 1)) & (F::MAX_EXP * 2 - 1)).to_i - (F::MAX_EXP - 1)
      mantissa = u & ~(U::MAX << (F::MANT_DIGITS - 1))

      io << '-' if negative
      if exponent >= F::MAX_EXP
        io << (mantissa == 0 ? "Infinity" : "NaN")
        return
      elsif exponent < F::MIN_EXP - 1 && mantissa == 0
        io << "0x0p+0"
        return
      end

      io << "0x"
      io << (exponent >= F::MIN_EXP - 1 ? '1' : '0')

      if mantissa != 0
        io << '.'
        while mantissa != 0
          digit = mantissa >> (F::MANT_DIGITS - 5)
          digit.to_s(io, base: 16)
          mantissa <<= 4
          mantissa &= ~(U::MAX << (F::MANT_DIGITS - 1))
        end
      end

      exponent += 1 if exponent < F::MIN_EXP - 1
      io << 'p'
      io << (exponent >= 0 ? '+' : '-')
      io << exponent.abs
    end
  end

  # Converts a hexadecimal floating-point literal to a `Float64`.
  #
  # The literal must match `/\A-?0x[0-9A-Fa-f]+(\.[0-9A-Fa-f]+)?p(+-)?[0-9]+(_?f64)?\z/`.
  # Inexact literals are rounded to the nearest representable `Float64`, ties-to-even.
  #
  # Does not support infinity and not-a-number.
  #
  # ```
  # HexFloat.to_f64("0x12.34p+5")      # => 582.5
  # HexFloat.to_f64("-0x0.555p-2_f64") # => -0.08331298828125
  # ```
  def self.to_f64(str : String) : Float64
    Converter(Float64, UInt64).to_f(str)
  end

  # Converts a hexadecimal floating-point literal to a `Float32`.
  #
  # The literal must match `/\A-?0x[0-9A-Fa-f]+(\.[0-9A-Fa-f]+)?p(+-)?[0-9]+(_?f32)?\z/`.
  # Inexact literals are rounded to the nearest representable `Float32`, ties-to-even.
  #
  # Does not support infinity and not-a-number.
  #
  # ```
  # HexFloat.to_f32("0x12.34p+5")      # => 582.5
  # HexFloat.to_f32("-0x0.555p-2_f32") # => -0.08331299
  # ```
  def self.to_f32(str : String) : Float32
    Converter(Float32, UInt32).to_f(str)
  end

  # Converts a hexadecimal floating-point literal to a `Float32` if it ends with
  # `f32`, a `Float64` otherwise.
  #
  # *str* must be a string literal. The return type is never a union.
  #
  # ```
  # x = HexFloat.to_f("0x12.34p+5")     # => 582.5
  # x.class                             # => Float64
  # x = HexFloat.to_f("0x12.34p+5_f32") # => 582.5
  # x.class                             # => Float32
  # ```
  macro to_f(str)
    {% raise "`str` must be a StringLiteral, not #{str.class_name}" unless str.is_a?(StringLiteral) %}
    {% if str.ends_with?("f32") %}
      ::HexFloat.to_f32({{ str }})
    {% else %}
      ::HexFloat.to_f64({{ str }})
    {% end %}
  end

  # Writes *num* to the given `IO` as a hexadecimal floating-point literal.
  def self.to_s(io : IO, num : Float64) : Nil
    Converter(Float64, UInt64).to_s(io, num)
  end

  # Returns the hexadecimal floating-point literal for the given *num*.
  #
  # Returns `Infinity` for infinity, `NaN` for not-a-number.
  #
  # ```
  # HexFloat.to_s(6.125)    # => "0x1.88p+2"
  # HexFloat.to_s(-1.0 / 3) # => "-0x1.5555555555555p-2"
  # ```
  def self.to_s(num : Float64) : String
    # -0x1.23456789abcdep-1023
    String.build(24) { |io| to_s(io, num) }
  end

  # Writes *num* to the given `IO` as a hexadecimal floating-point literal.
  def self.to_s(io : IO, num : Float32) : Nil
    Converter(Float32, UInt32).to_s(io, num)
  end

  # Returns the hexadecimal floating-point literal for the given *num*.
  #
  # Returns `Infinity` for infinity, `NaN` for not-a-number.
  #
  # ```
  # HexFloat.to_s(1.111_f32)  # => "0x1.1c6a7ep+0"
  # HexFloat.to_s(-1_f32 / 3) # => "-0x1.555556p-2"
  # ```
  def self.to_s(num : Float32) : String
    # -0x1.234567p-127
    String.build(16) { |io| to_s(io, num) }
  end
end
