require "./spec_helper"

# This file contains test cases derived from Microsoft's STL:
# https://github.com/microsoft/STL/tree/main/tests/std/tests/P0067R5_charconv
#
# Original license:
# Copyright (c) Microsoft Corporation.
# SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception

private def assert_to_s(num : F, str, *, file = __FILE__, line = __LINE__) forall F
  it file: file, line: line do
    assert_prints HexFloat.to_s(num), str, file: file, line: line
    unless num.infinite? || num.nan?
      {% if F == Float64 %}
        HexFloat.to_f64(str).should eq(num), file: file, line: line
      {% elsif F == Float32 %}
        HexFloat.to_f32(str).should eq(num), file: file, line: line
      {% end %}
    end
  end
end

describe HexFloat do
  describe ".to_f64" do
    it { HexFloat.to_f64("0x123p+0").should eq(291) }
    it { HexFloat.to_f64("0x123.0p+0").should eq(291) }
    it { HexFloat.to_f64("0x123p0").should eq(291) }
    it { HexFloat.to_f64("0x123p+0f64").should eq(291) }
    it { HexFloat.to_f64("0x123p+0_f64").should eq(291) }

    it { expect_raises(ArgumentError, "expected '0'") { HexFloat.to_f64("") } }
    it { expect_raises(ArgumentError, "expected '0'") { HexFloat.to_f64("1") } }
    it { expect_raises(ArgumentError, "expected 'x'") { HexFloat.to_f64("0") } }
    it { expect_raises(ArgumentError, "expected 'x'") { HexFloat.to_f64("01") } }
    it { expect_raises(ArgumentError, "empty integral part") { HexFloat.to_f64("0x") } }
    it { expect_raises(ArgumentError, "empty integral part") { HexFloat.to_f64("0x.") } }
    it { expect_raises(ArgumentError, "empty fractional part") { HexFloat.to_f64("0x1.") } }
    it { expect_raises(ArgumentError, "empty fractional part") { HexFloat.to_f64("0x1.p") } }
    it { expect_raises(ArgumentError, "expected 'p'") { HexFloat.to_f64("0x1") } }
    it { expect_raises(ArgumentError, "empty exponent") { HexFloat.to_f64("0x1p") } }
    it { expect_raises(ArgumentError, "empty exponent") { HexFloat.to_f64("0x1p+") } }
    it { expect_raises(ArgumentError, "empty exponent") { HexFloat.to_f64("0x1p-") } }
    it { expect_raises(ArgumentError, "exponent overflow") { HexFloat.to_f64("0x1p2147483648") } }
    it { expect_raises(ArgumentError, "exponent overflow") { HexFloat.to_f64("0x1p2147483650") } }
    it { expect_raises(ArgumentError, "exponent overflow") { HexFloat.to_f64("0x1p+2147483648") } }
    it { expect_raises(ArgumentError, "exponent overflow") { HexFloat.to_f64("0x1p+2147483650") } }
    it { expect_raises(ArgumentError, "exponent overflow") { HexFloat.to_f64("0x1p-2147483648") } }
    it { expect_raises(ArgumentError, "exponent overflow") { HexFloat.to_f64("0x1p-2147483650") } }
    it { expect_raises(ArgumentError, "trailing characters") { HexFloat.to_f64("0x1p0 ") } }
    it { expect_raises(ArgumentError, "trailing characters") { HexFloat.to_f64("0x1p0_f6") } }
    it { expect_raises(ArgumentError, "trailing characters") { HexFloat.to_f64("0x1p0f") } }

    it { HexFloat.to_f64("0x1.000000000000a000p+0").should eq(1.0000000000000022) } # exact
    it { HexFloat.to_f64("0x1.000000000000a001p+0").should eq(1.0000000000000022) } # below midpoint, round down
    it { HexFloat.to_f64("0x1.000000000000a800p+0").should eq(1.0000000000000022) } # midpoint, round down to even
    it { HexFloat.to_f64("0x1.000000000000a801p+0").should eq(1.0000000000000024) } # above midpoint, round up
    it { HexFloat.to_f64("0x1.000000000000b000p+0").should eq(1.0000000000000024) } # exact
    it { HexFloat.to_f64("0x1.000000000000b001p+0").should eq(1.0000000000000024) } # below midpoint, round down
    it { HexFloat.to_f64("0x1.000000000000b800p+0").should eq(1.0000000000000027) } # midpoint, round up to even
    it { HexFloat.to_f64("0x1.000000000000b801p+0").should eq(1.0000000000000027) } # above midpoint, round up

    it { HexFloat.to_f64("0x1.00000000000020p+0").should eq(1.0000000000000004) } # exact
    it { HexFloat.to_f64("0x1.00000000000021p+0").should eq(1.0000000000000004) } # below midpoint, round down
    it { HexFloat.to_f64("0x1.00000000000028p+0").should eq(1.0000000000000004) } # midpoint, round down to even
    it { HexFloat.to_f64("0x1.00000000000029p+0").should eq(1.0000000000000007) } # above midpoint, round up
    it { HexFloat.to_f64("0x1.00000000000030p+0").should eq(1.0000000000000007) } # exact
    it { HexFloat.to_f64("0x1.00000000000031p+0").should eq(1.0000000000000007) } # below midpoint, round down
    it { HexFloat.to_f64("0x1.00000000000038p+0").should eq(1.0000000000000009) } # midpoint, round up to even
    it { HexFloat.to_f64("0x1.00000000000039p+0").should eq(1.0000000000000009) } # above midpoint, round up

    # https://www.exploringbinary.com/nondeterministic-floating-point-conversions-in-java/
    it { HexFloat.to_f64("0x0.0000008p-1022").should eq(6.63123685e-316) }

    describe "round-to-nearest, ties-to-even" do
      it { HexFloat.to_f64("0x0.00000000000008p-1022").should eq(0.0) }
      it { HexFloat.to_f64("0x0.00000000000008#{"0" * 1000}1p-1022").should eq(5.0e-324) }

      it { HexFloat.to_f64("0x0.ffffffffffffe8p-1022").should eq(2.2250738585072004e-308) }
      it { HexFloat.to_f64("0x0.ffffffffffffe8#{"0" * 1000}1p-1022").should eq(2.225073858507201e-308) }

      it { HexFloat.to_f64("0x1.00000000000008p+0").should eq(1.0) }
      it { HexFloat.to_f64("0x1.00000000000008#{"0" * 1000}1p+0").should eq(1.0000000000000002) }

      it { HexFloat.to_f64("0x1.ffffffffffffe8p+0").should eq(1.9999999999999996) }
      it { HexFloat.to_f64("0x1.ffffffffffffe8#{"0" * 1000}1p+0").should eq(1.9999999999999998) }

      it { HexFloat.to_f64("0x1.00000000000008p+1023").should eq(8.98846567431158e307) }
      it { HexFloat.to_f64("0x1.00000000000008#{"0" * 1000}1p+1023").should eq(8.988465674311582e307) }

      it { HexFloat.to_f64("0x1.ffffffffffffe8p+1023").should eq(1.7976931348623155e308) }
      it { HexFloat.to_f64("0x1.ffffffffffffe8#{"0" * 1000}1p+1023").should eq(1.7976931348623157e308) }
    end

    describe "values close to MIN_POSITIVE and MAX" do
      it { HexFloat.to_f64("0x0.fffffffffffffp-1022").should eq(2.225073858507201e-308) }
      it { HexFloat.to_f64("0x1.0000000000000p-1022").should eq(2.2250738585072014e-308) }

      it { HexFloat.to_f64("0x1.ffffffffffffep-1023").should eq(2.225073858507201e-308) }
      it { HexFloat.to_f64("0x1.fffffffffffffp-1023").should eq(2.2250738585072014e-308) }
      it { HexFloat.to_f64("0x2.0000000000000p-1023").should eq(2.2250738585072014e-308) }

      it { HexFloat.to_f64("0x3.ffffffffffffcp-1024").should eq(2.225073858507201e-308) }
      it { HexFloat.to_f64("0x3.ffffffffffffdp-1024").should eq(2.225073858507201e-308) }
      it { HexFloat.to_f64("0x3.ffffffffffffep-1024").should eq(2.2250738585072014e-308) }
      it { HexFloat.to_f64("0x3.fffffffffffffp-1024").should eq(2.2250738585072014e-308) }
      it { HexFloat.to_f64("0x4.0000000000000p-1024").should eq(2.2250738585072014e-308) }

      it { HexFloat.to_f64("0x7.ffffffffffff8p-1025").should eq(2.225073858507201e-308) }
      it { HexFloat.to_f64("0x7.ffffffffffff9p-1025").should eq(2.225073858507201e-308) }
      it { HexFloat.to_f64("0x7.ffffffffffffbp-1025").should eq(2.225073858507201e-308) }
      it { HexFloat.to_f64("0x7.ffffffffffffcp-1025").should eq(2.2250738585072014e-308) }
      it { HexFloat.to_f64("0x7.ffffffffffffdp-1025").should eq(2.2250738585072014e-308) }
      it { HexFloat.to_f64("0x7.ffffffffffffep-1025").should eq(2.2250738585072014e-308) }
      it { HexFloat.to_f64("0x7.fffffffffffffp-1025").should eq(2.2250738585072014e-308) }
      it { HexFloat.to_f64("0x8.0000000000000p-1025").should eq(2.2250738585072014e-308) }

      it { HexFloat.to_f64("0x0.fffffffffffff0p-1022").should eq(2.225073858507201e-308) }
      it { HexFloat.to_f64("0x0.fffffffffffff1p-1022").should eq(2.225073858507201e-308) }
      it { HexFloat.to_f64("0x0.fffffffffffff7p-1022").should eq(2.225073858507201e-308) }
      it { HexFloat.to_f64("0x0.fffffffffffff8p-1022").should eq(2.2250738585072014e-308) }
      it { HexFloat.to_f64("0x0.fffffffffffff9p-1022").should eq(2.2250738585072014e-308) }
      it { HexFloat.to_f64("0x0.fffffffffffffbp-1022").should eq(2.2250738585072014e-308) }
      it { HexFloat.to_f64("0x0.fffffffffffffcp-1022").should eq(2.2250738585072014e-308) }
      it { HexFloat.to_f64("0x0.fffffffffffffdp-1022").should eq(2.2250738585072014e-308) }
      it { HexFloat.to_f64("0x0.ffffffffffffffp-1022").should eq(2.2250738585072014e-308) }
      it { HexFloat.to_f64("0x1.00000000000000p-1022").should eq(2.2250738585072014e-308) }

      it { HexFloat.to_f64("0x1.ffffffffffffe0p-1023").should eq(2.225073858507201e-308) }
      it { HexFloat.to_f64("0x1.ffffffffffffe1p-1023").should eq(2.225073858507201e-308) }
      it { HexFloat.to_f64("0x1.ffffffffffffefp-1023").should eq(2.225073858507201e-308) }
      it { HexFloat.to_f64("0x1.fffffffffffff0p-1023").should eq(2.2250738585072014e-308) }
      it { HexFloat.to_f64("0x1.fffffffffffff1p-1023").should eq(2.2250738585072014e-308) }
      it { HexFloat.to_f64("0x1.fffffffffffff7p-1023").should eq(2.2250738585072014e-308) }
      it { HexFloat.to_f64("0x1.fffffffffffff8p-1023").should eq(2.2250738585072014e-308) }
      it { HexFloat.to_f64("0x1.fffffffffffff9p-1023").should eq(2.2250738585072014e-308) }
      it { HexFloat.to_f64("0x1.ffffffffffffffp-1023").should eq(2.2250738585072014e-308) }
      it { HexFloat.to_f64("0x2.00000000000000p-1023").should eq(2.2250738585072014e-308) }

      it { HexFloat.to_f64("0x3.ffffffffffffc0p-1024").should eq(2.225073858507201e-308) }
      it { HexFloat.to_f64("0x3.ffffffffffffc1p-1024").should eq(2.225073858507201e-308) }
      it { HexFloat.to_f64("0x3.ffffffffffffdfp-1024").should eq(2.225073858507201e-308) }
      it { HexFloat.to_f64("0x3.ffffffffffffe0p-1024").should eq(2.2250738585072014e-308) }
      it { HexFloat.to_f64("0x3.ffffffffffffe1p-1024").should eq(2.2250738585072014e-308) }
      it { HexFloat.to_f64("0x3.ffffffffffffefp-1024").should eq(2.2250738585072014e-308) }
      it { HexFloat.to_f64("0x3.fffffffffffff0p-1024").should eq(2.2250738585072014e-308) }
      it { HexFloat.to_f64("0x3.fffffffffffff1p-1024").should eq(2.2250738585072014e-308) }
      it { HexFloat.to_f64("0x3.ffffffffffffffp-1024").should eq(2.2250738585072014e-308) }
      it { HexFloat.to_f64("0x4.00000000000000p-1024").should eq(2.2250738585072014e-308) }

      it { HexFloat.to_f64("0x7.ffffffffffff80p-1025").should eq(2.225073858507201e-308) }
      it { HexFloat.to_f64("0x7.ffffffffffff81p-1025").should eq(2.225073858507201e-308) }
      it { HexFloat.to_f64("0x7.ffffffffffffbfp-1025").should eq(2.225073858507201e-308) }
      it { HexFloat.to_f64("0x7.ffffffffffffc0p-1025").should eq(2.2250738585072014e-308) }
      it { HexFloat.to_f64("0x7.ffffffffffffc1p-1025").should eq(2.2250738585072014e-308) }
      it { HexFloat.to_f64("0x7.ffffffffffffdfp-1025").should eq(2.2250738585072014e-308) }
      it { HexFloat.to_f64("0x7.ffffffffffffe0p-1025").should eq(2.2250738585072014e-308) }
      it { HexFloat.to_f64("0x7.ffffffffffffe1p-1025").should eq(2.2250738585072014e-308) }
      it { HexFloat.to_f64("0x7.ffffffffffffffp-1025").should eq(2.2250738585072014e-308) }
      it { HexFloat.to_f64("0x8.00000000000000p-1025").should eq(2.2250738585072014e-308) }

      it { HexFloat.to_f64("0x1.fffffffffffffp+1023").should eq(1.7976931348623157e+308) }
      it { HexFloat.to_f64("0x2.0000000000000p+1023").should eq(Float64::INFINITY) }

      it { HexFloat.to_f64("0x3.ffffffffffffep+1022").should eq(1.7976931348623157e+308) }
      it { HexFloat.to_f64("0x3.fffffffffffffp+1022").should eq(Float64::INFINITY) }
      it { HexFloat.to_f64("0x4.0000000000000p+1022").should eq(Float64::INFINITY) }

      it { HexFloat.to_f64("0x7.ffffffffffffcp+1021").should eq(1.7976931348623157e+308) }
      it { HexFloat.to_f64("0x7.ffffffffffffdp+1021").should eq(1.7976931348623157e+308) }
      it { HexFloat.to_f64("0x7.ffffffffffffep+1021").should eq(Float64::INFINITY) }
      it { HexFloat.to_f64("0x7.fffffffffffffp+1021").should eq(Float64::INFINITY) }
      it { HexFloat.to_f64("0x8.0000000000000p+1021").should eq(Float64::INFINITY) }

      it { HexFloat.to_f64("0x0.fffffffffffff8p+1024").should eq(1.7976931348623157e+308) }
      it { HexFloat.to_f64("0x0.fffffffffffff9p+1024").should eq(1.7976931348623157e+308) }
      it { HexFloat.to_f64("0x0.fffffffffffffbp+1024").should eq(1.7976931348623157e+308) }
      it { HexFloat.to_f64("0x0.fffffffffffffcp+1024").should eq(Float64::INFINITY) }
      it { HexFloat.to_f64("0x0.fffffffffffffdp+1024").should eq(Float64::INFINITY) }
      it { HexFloat.to_f64("0x0.ffffffffffffffp+1024").should eq(Float64::INFINITY) }
      it { HexFloat.to_f64("0x1.00000000000000p+1024").should eq(Float64::INFINITY) }

      it { HexFloat.to_f64("0x1.fffffffffffff0p+1023").should eq(1.7976931348623157e+308) }
      it { HexFloat.to_f64("0x1.fffffffffffff1p+1023").should eq(1.7976931348623157e+308) }
      it { HexFloat.to_f64("0x1.fffffffffffff7p+1023").should eq(1.7976931348623157e+308) }
      it { HexFloat.to_f64("0x1.fffffffffffff8p+1023").should eq(Float64::INFINITY) }
      it { HexFloat.to_f64("0x1.fffffffffffff9p+1023").should eq(Float64::INFINITY) }
      it { HexFloat.to_f64("0x1.ffffffffffffffp+1023").should eq(Float64::INFINITY) }
      it { HexFloat.to_f64("0x2.00000000000000p+1023").should eq(Float64::INFINITY) }

      it { HexFloat.to_f64("0x3.ffffffffffffe0p+1022").should eq(1.7976931348623157e+308) }
      it { HexFloat.to_f64("0x3.ffffffffffffe1p+1022").should eq(1.7976931348623157e+308) }
      it { HexFloat.to_f64("0x3.ffffffffffffefp+1022").should eq(1.7976931348623157e+308) }
      it { HexFloat.to_f64("0x3.fffffffffffff0p+1022").should eq(Float64::INFINITY) }
      it { HexFloat.to_f64("0x3.fffffffffffff1p+1022").should eq(Float64::INFINITY) }
      it { HexFloat.to_f64("0x3.ffffffffffffffp+1022").should eq(Float64::INFINITY) }
      it { HexFloat.to_f64("0x4.00000000000000p+1022").should eq(Float64::INFINITY) }

      it { HexFloat.to_f64("0x7.ffffffffffffc0p+1021").should eq(1.7976931348623157e+308) }
      it { HexFloat.to_f64("0x7.ffffffffffffc1p+1021").should eq(1.7976931348623157e+308) }
      it { HexFloat.to_f64("0x7.ffffffffffffdfp+1021").should eq(1.7976931348623157e+308) }
      it { HexFloat.to_f64("0x7.ffffffffffffe0p+1021").should eq(Float64::INFINITY) }
      it { HexFloat.to_f64("0x7.ffffffffffffe1p+1021").should eq(Float64::INFINITY) }
      it { HexFloat.to_f64("0x7.ffffffffffffffp+1021").should eq(Float64::INFINITY) }
      it { HexFloat.to_f64("0x8.00000000000000p+1021").should eq(Float64::INFINITY) }

      it { HexFloat.to_f64("0x0.fffffffffffff80p+1024").should eq(1.7976931348623157e+308) }
      it { HexFloat.to_f64("0x0.fffffffffffff81p+1024").should eq(1.7976931348623157e+308) }
      it { HexFloat.to_f64("0x0.fffffffffffffbfp+1024").should eq(1.7976931348623157e+308) }
      it { HexFloat.to_f64("0x0.fffffffffffffc0p+1024").should eq(Float64::INFINITY) }
      it { HexFloat.to_f64("0x0.fffffffffffffc1p+1024").should eq(Float64::INFINITY) }
      it { HexFloat.to_f64("0x0.fffffffffffffffp+1024").should eq(Float64::INFINITY) }
      it { HexFloat.to_f64("0x1.000000000000000p+1024").should eq(Float64::INFINITY) }
    end
  end

  describe ".to_f32" do
    it { HexFloat.to_f32("0x123p+0").should eq(291_f32) }
    it { HexFloat.to_f32("0x123.0p+0").should eq(291_f32) }
    it { HexFloat.to_f32("0x123p0").should eq(291_f32) }
    it { HexFloat.to_f32("0x123p+0f32").should eq(291_f32) }
    it { HexFloat.to_f32("0x123p+0_f32").should eq(291_f32) }

    it { HexFloat.to_f32("0x1.a0000400p+0_f32").should eq(1.6250002_f32) } # exact
    it { HexFloat.to_f32("0x1.a0000401p+0_f32").should eq(1.6250002_f32) } # below midpoint, round down
    it { HexFloat.to_f32("0x1.a0000500p+0_f32").should eq(1.6250002_f32) } # midpoint, round down to even
    it { HexFloat.to_f32("0x1.a0000501p+0_f32").should eq(1.6250004_f32) } # above midpoint, round up
    it { HexFloat.to_f32("0x1.a0000600p+0_f32").should eq(1.6250004_f32) } # exact
    it { HexFloat.to_f32("0x1.a0000601p+0_f32").should eq(1.6250004_f32) } # below midpoint, round down
    it { HexFloat.to_f32("0x1.a0000700p+0_f32").should eq(1.6250005_f32) } # midpoint, round up to even
    it { HexFloat.to_f32("0x1.a0000701p+0_f32").should eq(1.6250005_f32) } # above midpoint, round up

    it { HexFloat.to_f32("0x1.0000040p+0f32").should eq(1.0000002_f32) } # exact
    it { HexFloat.to_f32("0x1.0000041p+0f32").should eq(1.0000002_f32) } # below midpoint, round down
    it { HexFloat.to_f32("0x1.0000050p+0f32").should eq(1.0000002_f32) } # midpoint, round down to even
    it { HexFloat.to_f32("0x1.0000051p+0f32").should eq(1.0000004_f32) } # above midpoint, round up
    it { HexFloat.to_f32("0x1.0000060p+0f32").should eq(1.0000004_f32) } # exact
    it { HexFloat.to_f32("0x1.0000061p+0f32").should eq(1.0000004_f32) } # below midpoint, round down
    it { HexFloat.to_f32("0x1.0000070p+0f32").should eq(1.0000005_f32) } # midpoint, round up to even
    it { HexFloat.to_f32("0x1.0000071p+0f32").should eq(1.0000005_f32) } # above midpoint, round up

    describe "values close to MIN_POSITIVE and MAX" do
      it { HexFloat.to_f32("0x7.fffffp-129_f32").should eq(1.1754942e-38_f32) }
      it { HexFloat.to_f32("0x8.00000p-129_f32").should eq(1.1754944e-38_f32) }

      it { HexFloat.to_f32("0x0.fffffep-126_f32").should eq(1.1754942e-38_f32) }
      it { HexFloat.to_f32("0x0.ffffffp-126_f32").should eq(1.1754944e-38_f32) }
      it { HexFloat.to_f32("0x1.000000p-126_f32").should eq(1.1754944e-38_f32) }

      it { HexFloat.to_f32("0x1.fffffcp-127_f32").should eq(1.1754942e-38_f32) }
      it { HexFloat.to_f32("0x1.fffffdp-127_f32").should eq(1.1754942e-38_f32) }
      it { HexFloat.to_f32("0x1.fffffep-127_f32").should eq(1.1754944e-38_f32) }
      it { HexFloat.to_f32("0x1.ffffffp-127_f32").should eq(1.1754944e-38_f32) }
      it { HexFloat.to_f32("0x2.000000p-127_f32").should eq(1.1754944e-38_f32) }

      it { HexFloat.to_f32("0x3.fffff8p-128_f32").should eq(1.1754942e-38_f32) }
      it { HexFloat.to_f32("0x3.fffff9p-128_f32").should eq(1.1754942e-38_f32) }
      it { HexFloat.to_f32("0x3.fffffbp-128_f32").should eq(1.1754942e-38_f32) }
      it { HexFloat.to_f32("0x3.fffffcp-128_f32").should eq(1.1754944e-38_f32) }
      it { HexFloat.to_f32("0x3.fffffdp-128_f32").should eq(1.1754944e-38_f32) }
      it { HexFloat.to_f32("0x3.fffffep-128_f32").should eq(1.1754944e-38_f32) }
      it { HexFloat.to_f32("0x3.ffffffp-128_f32").should eq(1.1754944e-38_f32) }
      it { HexFloat.to_f32("0x4.000000p-128_f32").should eq(1.1754944e-38_f32) }

      it { HexFloat.to_f32("0x7.fffff0p-129_f32").should eq(1.1754942e-38_f32) }
      it { HexFloat.to_f32("0x7.fffff1p-129_f32").should eq(1.1754942e-38_f32) }
      it { HexFloat.to_f32("0x7.fffff7p-129_f32").should eq(1.1754942e-38_f32) }
      it { HexFloat.to_f32("0x7.fffff8p-129_f32").should eq(1.1754944e-38_f32) }
      it { HexFloat.to_f32("0x7.fffff9p-129_f32").should eq(1.1754944e-38_f32) }
      it { HexFloat.to_f32("0x7.fffffbp-129_f32").should eq(1.1754944e-38_f32) }
      it { HexFloat.to_f32("0x7.fffffcp-129_f32").should eq(1.1754944e-38_f32) }
      it { HexFloat.to_f32("0x7.fffffdp-129_f32").should eq(1.1754944e-38_f32) }
      it { HexFloat.to_f32("0x7.ffffffp-129_f32").should eq(1.1754944e-38_f32) }
      it { HexFloat.to_f32("0x8.000000p-129_f32").should eq(1.1754944e-38_f32) }

      it { HexFloat.to_f32("0x0.fffffe0p-126_f32").should eq(1.1754942e-38_f32) }
      it { HexFloat.to_f32("0x0.fffffe1p-126_f32").should eq(1.1754942e-38_f32) }
      it { HexFloat.to_f32("0x0.fffffefp-126_f32").should eq(1.1754942e-38_f32) }
      it { HexFloat.to_f32("0x0.ffffff0p-126_f32").should eq(1.1754944e-38_f32) }
      it { HexFloat.to_f32("0x0.ffffff1p-126_f32").should eq(1.1754944e-38_f32) }
      it { HexFloat.to_f32("0x0.ffffff7p-126_f32").should eq(1.1754944e-38_f32) }
      it { HexFloat.to_f32("0x0.ffffff8p-126_f32").should eq(1.1754944e-38_f32) }
      it { HexFloat.to_f32("0x0.ffffff9p-126_f32").should eq(1.1754944e-38_f32) }
      it { HexFloat.to_f32("0x0.fffffffp-126_f32").should eq(1.1754944e-38_f32) }
      it { HexFloat.to_f32("0x1.0000000p-126_f32").should eq(1.1754944e-38_f32) }

      it { HexFloat.to_f32("0x1.fffffc0p-127_f32").should eq(1.1754942e-38_f32) }
      it { HexFloat.to_f32("0x1.fffffc1p-127_f32").should eq(1.1754942e-38_f32) }
      it { HexFloat.to_f32("0x1.fffffdfp-127_f32").should eq(1.1754942e-38_f32) }
      it { HexFloat.to_f32("0x1.fffffe0p-127_f32").should eq(1.1754944e-38_f32) }
      it { HexFloat.to_f32("0x1.fffffe1p-127_f32").should eq(1.1754944e-38_f32) }
      it { HexFloat.to_f32("0x1.fffffefp-127_f32").should eq(1.1754944e-38_f32) }
      it { HexFloat.to_f32("0x1.ffffff0p-127_f32").should eq(1.1754944e-38_f32) }
      it { HexFloat.to_f32("0x1.ffffff1p-127_f32").should eq(1.1754944e-38_f32) }
      it { HexFloat.to_f32("0x1.fffffffp-127_f32").should eq(1.1754944e-38_f32) }
      it { HexFloat.to_f32("0x2.0000000p-127_f32").should eq(1.1754944e-38_f32) }

      it { HexFloat.to_f32("0x3.fffff80p-128_f32").should eq(1.1754942e-38_f32) }
      it { HexFloat.to_f32("0x3.fffff81p-128_f32").should eq(1.1754942e-38_f32) }
      it { HexFloat.to_f32("0x3.fffffbfp-128_f32").should eq(1.1754942e-38_f32) }
      it { HexFloat.to_f32("0x3.fffffc0p-128_f32").should eq(1.1754944e-38_f32) }
      it { HexFloat.to_f32("0x3.fffffc1p-128_f32").should eq(1.1754944e-38_f32) }
      it { HexFloat.to_f32("0x3.fffffdfp-128_f32").should eq(1.1754944e-38_f32) }
      it { HexFloat.to_f32("0x3.fffffe0p-128_f32").should eq(1.1754944e-38_f32) }
      it { HexFloat.to_f32("0x3.fffffe1p-128_f32").should eq(1.1754944e-38_f32) }
      it { HexFloat.to_f32("0x3.fffffffp-128_f32").should eq(1.1754944e-38_f32) }
      it { HexFloat.to_f32("0x4.0000000p-128_f32").should eq(1.1754944e-38_f32) }

      it { HexFloat.to_f32("0x0.ffffffp+128_f32").should eq(3.4028235e+38_f32) }
      it { HexFloat.to_f32("0x1.000000p+128_f32").should eq(Float32::INFINITY) }

      it { HexFloat.to_f32("0x1.fffffep+127_f32").should eq(3.4028235e+38_f32) }
      it { HexFloat.to_f32("0x1.ffffffp+127_f32").should eq(Float32::INFINITY) }
      it { HexFloat.to_f32("0x2.000000p+127_f32").should eq(Float32::INFINITY) }

      it { HexFloat.to_f32("0x3.fffffcp+126_f32").should eq(3.4028235e+38_f32) }
      it { HexFloat.to_f32("0x3.fffffdp+126_f32").should eq(3.4028235e+38_f32) }
      it { HexFloat.to_f32("0x3.fffffep+126_f32").should eq(Float32::INFINITY) }
      it { HexFloat.to_f32("0x3.ffffffp+126_f32").should eq(Float32::INFINITY) }
      it { HexFloat.to_f32("0x4.000000p+126_f32").should eq(Float32::INFINITY) }

      it { HexFloat.to_f32("0x7.fffff8p+125_f32").should eq(3.4028235e+38_f32) }
      it { HexFloat.to_f32("0x7.fffff9p+125_f32").should eq(3.4028235e+38_f32) }
      it { HexFloat.to_f32("0x7.fffffbp+125_f32").should eq(3.4028235e+38_f32) }
      it { HexFloat.to_f32("0x7.fffffcp+125_f32").should eq(Float32::INFINITY) }
      it { HexFloat.to_f32("0x7.fffffdp+125_f32").should eq(Float32::INFINITY) }
      it { HexFloat.to_f32("0x7.ffffffp+125_f32").should eq(Float32::INFINITY) }
      it { HexFloat.to_f32("0x8.000000p+125_f32").should eq(Float32::INFINITY) }

      it { HexFloat.to_f32("0x0.ffffff0p+128_f32").should eq(3.4028235e+38_f32) }
      it { HexFloat.to_f32("0x0.ffffff1p+128_f32").should eq(3.4028235e+38_f32) }
      it { HexFloat.to_f32("0x0.ffffff7p+128_f32").should eq(3.4028235e+38_f32) }
      it { HexFloat.to_f32("0x0.ffffff8p+128_f32").should eq(Float32::INFINITY) }
      it { HexFloat.to_f32("0x0.ffffff9p+128_f32").should eq(Float32::INFINITY) }
      it { HexFloat.to_f32("0x0.fffffffp+128_f32").should eq(Float32::INFINITY) }
      it { HexFloat.to_f32("0x1.0000000p+128_f32").should eq(Float32::INFINITY) }

      it { HexFloat.to_f32("0x1.fffffe0p+127_f32").should eq(3.4028235e+38_f32) }
      it { HexFloat.to_f32("0x1.fffffe1p+127_f32").should eq(3.4028235e+38_f32) }
      it { HexFloat.to_f32("0x1.fffffefp+127_f32").should eq(3.4028235e+38_f32) }
      it { HexFloat.to_f32("0x1.ffffff0p+127_f32").should eq(Float32::INFINITY) }
      it { HexFloat.to_f32("0x1.ffffff1p+127_f32").should eq(Float32::INFINITY) }
      it { HexFloat.to_f32("0x1.fffffffp+127_f32").should eq(Float32::INFINITY) }
      it { HexFloat.to_f32("0x2.0000000p+127_f32").should eq(Float32::INFINITY) }

      it { HexFloat.to_f32("0x3.fffffc0p+126_f32").should eq(3.4028235e+38_f32) }
      it { HexFloat.to_f32("0x3.fffffc1p+126_f32").should eq(3.4028235e+38_f32) }
      it { HexFloat.to_f32("0x3.fffffdfp+126_f32").should eq(3.4028235e+38_f32) }
      it { HexFloat.to_f32("0x3.fffffe0p+126_f32").should eq(Float32::INFINITY) }
      it { HexFloat.to_f32("0x3.fffffe1p+126_f32").should eq(Float32::INFINITY) }
      it { HexFloat.to_f32("0x3.fffffffp+126_f32").should eq(Float32::INFINITY) }
      it { HexFloat.to_f32("0x4.0000000p+126_f32").should eq(Float32::INFINITY) }

      it { HexFloat.to_f32("0x7.fffff80p+125_f32").should eq(3.4028235e+38_f32) }
      it { HexFloat.to_f32("0x7.fffff81p+125_f32").should eq(3.4028235e+38_f32) }
      it { HexFloat.to_f32("0x7.fffffbfp+125_f32").should eq(3.4028235e+38_f32) }
      it { HexFloat.to_f32("0x7.fffffc0p+125_f32").should eq(Float32::INFINITY) }
      it { HexFloat.to_f32("0x7.fffffc1p+125_f32").should eq(Float32::INFINITY) }
      it { HexFloat.to_f32("0x7.fffffffp+125_f32").should eq(Float32::INFINITY) }
      it { HexFloat.to_f32("0x8.0000000p+125_f32").should eq(Float32::INFINITY) }
    end
  end

  describe ".to_f" do
    it "converts to Float64 without suffix" do
      x = HexFloat.to_f("0x123p+0")
      x.should be_a(Float64)
      x.should eq(0x123)
    end

    it "converts to Float64 with `f64` suffix" do
      x = HexFloat.to_f("0x123p+0f64")
      x.should be_a(Float64)
      x.should eq(0x123)
    end

    it "converts to Float64 with `_f64` suffix" do
      x = HexFloat.to_f("0x123p+0_f64")
      x.should be_a(Float64)
      x.should eq(0x123)
    end

    it "converts to Float32 with `f32` suffix" do
      x = HexFloat.to_f("0x123p+0f32")
      x.should be_a(Float32)
      x.should eq(0x123)
    end

    it "converts to Float32 with `_f32` suffix" do
      x = HexFloat.to_f("0x123p+0_f32")
      x.should be_a(Float32)
      x.should eq(0x123)
    end
  end

  describe ".to_s(Float64)" do
    describe "special cases" do
      it { assert_prints HexFloat.to_s(0.0), "0x0p+0" }
      it { assert_prints HexFloat.to_s(-0.0), "-0x0p+0" }
      it { assert_prints HexFloat.to_s(Float64::INFINITY), "Infinity" }
      it { assert_prints HexFloat.to_s(-Float64::INFINITY), "-Infinity" }
      it { assert_prints HexFloat.to_s(Float64::NAN), "NaN" }
      it { assert_prints HexFloat.to_s(1.447509765625), "0x1.729p+0" }
      it { assert_prints HexFloat.to_s(-1.447509765625), "-0x1.729p+0" }
    end

    describe "corner cases" do
      it { assert_prints HexFloat.to_s(1.447265625), "0x1.728p+0" }                         # instead of "2.e5p-1"
      it { assert_prints HexFloat.to_s(5.0e-324), "0x0.0000000000001p-1022" }               # instead of "1p-1074", min subnormal
      it { assert_prints HexFloat.to_s(2.225073858507201e-308), "0x0.fffffffffffffp-1022" } # max subnormal
      it { assert_prints HexFloat.to_s(Float64::MIN_POSITIVE), "0x1p-1022" }                # min normal
      it { assert_prints HexFloat.to_s(Float64::MAX), "0x1.fffffffffffffp+1023" }           # max normal
    end

    describe "exponents" do
      it { assert_prints HexFloat.to_s(1.8227805048890994e-304), "0x1p-1009" }
      it { assert_prints HexFloat.to_s(1.8665272370064378e-301), "0x1p-999" }
      it { assert_prints HexFloat.to_s(1.5777218104420236e-30), "0x1p-99" }
      it { assert_prints HexFloat.to_s(0.001953125), "0x1p-9" }
      it { assert_prints HexFloat.to_s(1.0), "0x1p+0" }
      it { assert_prints HexFloat.to_s(512.0), "0x1p+9" }
      it { assert_prints HexFloat.to_s(6.338253001141147e+29), "0x1p+99" }
      it { assert_prints HexFloat.to_s(5.357543035931337e+300), "0x1p+999" }
      it { assert_prints HexFloat.to_s(5.486124068793689e+303), "0x1p+1009" }
    end

    describe "hexits" do
      it { assert_prints HexFloat.to_s(1.0044444443192333), "0x1.01234567p+0" }
      it { assert_prints HexFloat.to_s(1.5377777775283903), "0x1.89abcdefp+0" }
    end

    describe "trimming" do
      it { assert_prints HexFloat.to_s(1.0000000000000022), "0x1.000000000000ap+0" }
      it { assert_prints HexFloat.to_s(1.0000000000000355), "0x1.00000000000ap+0" }
      it { assert_prints HexFloat.to_s(1.0000000000005684), "0x1.0000000000ap+0" }
      it { assert_prints HexFloat.to_s(1.000000000009095), "0x1.000000000ap+0" }
      it { assert_prints HexFloat.to_s(1.0000000001455192), "0x1.00000000ap+0" }
      it { assert_prints HexFloat.to_s(1.0000000023283064), "0x1.0000000ap+0" }
      it { assert_prints HexFloat.to_s(1.000000037252903), "0x1.000000ap+0" }
      it { assert_prints HexFloat.to_s(1.0000005960464478), "0x1.00000ap+0" }
      it { assert_prints HexFloat.to_s(1.000009536743164), "0x1.0000ap+0" }
      it { assert_prints HexFloat.to_s(1.000152587890625), "0x1.000ap+0" }
      it { assert_prints HexFloat.to_s(1.00244140625), "0x1.00ap+0" }
      it { assert_prints HexFloat.to_s(1.0390625), "0x1.0ap+0" }
      it { assert_prints HexFloat.to_s(1.625), "0x1.ap+0" }
      it { assert_prints HexFloat.to_s(1.0), "0x1p+0" }
    end
  end

  describe ".to_s(Float32)" do
    describe "special cases" do
      it { assert_prints HexFloat.to_s(0.0_f32), "0x0p+0" }
      it { assert_prints HexFloat.to_s(-0.0_f32), "-0x0p+0" }
      it { assert_prints HexFloat.to_s(Float32::INFINITY), "Infinity" }
      it { assert_prints HexFloat.to_s(-Float32::INFINITY), "-Infinity" }
      it { assert_prints HexFloat.to_s(Float32::NAN), "NaN" }
      it { assert_prints HexFloat.to_s(1.4475098_f32), "0x1.729p+0" }
      it { assert_prints HexFloat.to_s(-1.4475098_f32), "-0x1.729p+0" }
    end

    describe "corner cases" do
      it { assert_prints HexFloat.to_s(1.4472656_f32), "0x1.728p+0" }          # instead of "2.e5p-1"
      it { assert_prints HexFloat.to_s(1.0e-45_f32), "0x0.000002p-126" }       # instead of "1p-1074", min subnormal
      it { assert_prints HexFloat.to_s(1.1754942e-38_f32), "0x0.fffffep-126" } # max subnormal
      it { assert_prints HexFloat.to_s(Float32::MIN_POSITIVE), "0x1p-126" }    # min normal
      it { assert_prints HexFloat.to_s(Float32::MAX), "0x1.fffffep+127" }      # max normal
    end

    describe "exponents" do
      it { assert_prints HexFloat.to_s(1.540744e-33_f32), "0x1p-109" }
      it { assert_prints HexFloat.to_s(1.5777218e-30_f32), "0x1p-99" }
      it { assert_prints HexFloat.to_s(0.001953125_f32), "0x1p-9" }
      it { assert_prints HexFloat.to_s(1.0_f32), "0x1p+0" }
      it { assert_prints HexFloat.to_s(512.0_f32), "0x1p+9" }
      it { assert_prints HexFloat.to_s(6.338253e+29_f32), "0x1p+99" }
      it { assert_prints HexFloat.to_s(6.490371e+32_f32), "0x1p+109" }
    end

    describe "hexits" do
      it { assert_prints HexFloat.to_s(1.0044403_f32), "0x1.0123p+0" }
      it { assert_prints HexFloat.to_s(1.2711029_f32), "0x1.4567p+0" }
      it { assert_prints HexFloat.to_s(1.5377655_f32), "0x1.89abp+0" }
      it { assert_prints HexFloat.to_s(1.8044281_f32), "0x1.cdefp+0" }
    end

    describe "trimming" do
      it { assert_prints HexFloat.to_s(1.0000006_f32), "0x1.00000ap+0" }
      it { assert_prints HexFloat.to_s(1.0000095_f32), "0x1.0000ap+0" }
      it { assert_prints HexFloat.to_s(1.0001526_f32), "0x1.000ap+0" }
      it { assert_prints HexFloat.to_s(1.0390625_f32), "0x1.0ap+0" }
      it { assert_prints HexFloat.to_s(1.0024414_f32), "0x1.00ap+0" }
      it { assert_prints HexFloat.to_s(1.625_f32), "0x1.ap+0" }
      it { assert_prints HexFloat.to_s(1.0_f32), "0x1p+0" }
    end
  end
end
