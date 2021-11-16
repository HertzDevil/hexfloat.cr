# hexfloat

Provides conversion functions between hexadecimal floating-point literals and
floating-point values.

## Installation

1. Add the dependency to your `shard.yml`:

   ```yaml
   dependencies:
     hexfloat:
       github: HertzDevil/hexfloat
   ```

2. Run `shards install`

## Usage

```crystal
require "hexfloat"

HexFloat.to_f64("0x12.34p+5")    # => 582.5
HexFloat.to_f32("0x3.333334p+1") # => 6.4_f32

HexFloat.to_f("0x12.34p+5")    # => 582.5
HexFloat.to_f("0x12.34p+5f32") # => 582.5_f32

HexFloat.to_s(6.125)      # => "0x1.88p+2"
HexFloat.to_s(-1_f32 / 3) # => "-0x1.555556p-2"

String.build do |io|
  HexFloat.to_s(io, 6.125)
  HexFloat.to_s(io, -1_f32 / 3)
end
```

## Contributing

1. Fork it (<https://github.com/HertzDevil/hexfloat/fork>)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## Contributors

- [Quinton Miller](https://github.com/HertzDevil) - creator and maintainer
