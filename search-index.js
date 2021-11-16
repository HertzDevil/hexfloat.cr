crystal_doc_search_index_callback({"repository_name":"hexfloat","body":"# hexfloat\n\nProvides conversion functions between hexadecimal floating-point literals and\nfloating-point values.\n\n## Installation\n\n1. Add the dependency to your `shard.yml`:\n\n   ```yaml\n   dependencies:\n     hexfloat:\n       github: HertzDevil/hexfloat\n   ```\n\n2. Run `shards install`\n\n## Usage\n\n```crystal\nrequire \"hexfloat\"\n\nHexFloat.to_f64(\"0x12.34p+5\")    # => 582.5\nHexFloat.to_f32(\"0x3.333334p+1\") # => 6.4\n\nHexFloat.to_s(6.125)      # => \"0x1.88p+2\"\nHexFloat.to_s(-1_f32 / 3) # => \"-0x1.555556p-2\"\n\nString.build do |io|\n  HexFloat.to_s(io, 6.125)\n  HexFloat.to_s(io, -1_f32 / 3)\nend\n```\n\n## Contributing\n\n1. Fork it (<https://github.com/HertzDevil/hexfloat/fork>)\n2. Create your feature branch (`git checkout -b my-new-feature`)\n3. Commit your changes (`git commit -am 'Add some feature'`)\n4. Push to the branch (`git push origin my-new-feature`)\n5. Create a new Pull Request\n\n## Contributors\n\n- [Quinton Miller](https://github.com/HertzDevil) - creator and maintainer\n","program":{"html_id":"hexfloat/toplevel","path":"toplevel.html","kind":"module","full_name":"Top Level Namespace","name":"Top Level Namespace","abstract":false,"superclass":null,"ancestors":[],"locations":[],"repository_name":"hexfloat","program":true,"enum":false,"alias":false,"aliased":null,"aliased_html":null,"const":false,"constants":[],"included_modules":[],"extended_modules":[],"subclasses":[],"including_types":[],"namespace":null,"doc":null,"summary":null,"class_methods":[],"constructors":[],"instance_methods":[],"macros":[],"types":[{"html_id":"hexfloat/HexFloat","path":"HexFloat.html","kind":"module","full_name":"HexFloat","name":"HexFloat","abstract":false,"superclass":null,"ancestors":[],"locations":[{"filename":"src/hexfloat.cr","line_number":3,"url":"https://github.com/HertzDevil/hexfloat.cr/blob/4f17429f5d7da13812e14370f9bbaf4171ed3063/src/hexfloat.cr#L3"}],"repository_name":"hexfloat","program":false,"enum":false,"alias":false,"aliased":null,"aliased_html":null,"const":false,"constants":[{"id":"VERSION","name":"VERSION","value":"\"1.0.0\"","doc":null,"summary":null}],"included_modules":[],"extended_modules":[],"subclasses":[],"including_types":[],"namespace":null,"doc":"Provides conversion functions between hexadecimal floating-point literals and\nfloating-point values.","summary":"<p>Provides conversion functions between hexadecimal floating-point literals and floating-point values.</p>","class_methods":[{"html_id":"to_f32(str:String):Float32-class-method","name":"to_f32","doc":"Converts a hexadecimal floating-point literal to a `Float32`.\n\nThe literal must match `/\\A-?0x[0-9A-Fa-f]+(\\.[0-9A-Fa-f]+)?p(+-)?[0-9]+(_?f32)?\\z/`.\nInexact literals are rounded to the nearest representable `Float32`, ties-to-even.\n\nDoes not support infinity and not-a-number.\n\n```\nHexFloat.to_f32(\"0x12.34p+5\")      # => 582.5\nHexFloat.to_f32(\"-0x0.555p-2_f32\") # => -0.08331299\n```","summary":"<p>Converts a hexadecimal floating-point literal to a <code>Float32</code>.</p>","abstract":false,"args":[{"name":"str","doc":null,"default_value":"","external_name":"str","restriction":"String"}],"args_string":"(str : String) : Float32","args_html":"(str : String) : Float32","location":{"filename":"src/hexfloat.cr","line_number":267,"url":"https://github.com/HertzDevil/hexfloat.cr/blob/4f17429f5d7da13812e14370f9bbaf4171ed3063/src/hexfloat.cr#L267"},"def":{"name":"to_f32","args":[{"name":"str","doc":null,"default_value":"","external_name":"str","restriction":"String"}],"double_splat":null,"splat_index":null,"yields":null,"block_arg":null,"return_type":"Float32","visibility":"Public","body":"Converter(Float32, UInt32).to_f(str)"}},{"html_id":"to_f64(str:String):Float64-class-method","name":"to_f64","doc":"Converts a hexadecimal floating-point literal to a `Float64`.\n\nThe literal must match `/\\A-?0x[0-9A-Fa-f]+(\\.[0-9A-Fa-f]+)?p(+-)?[0-9]+(_?f64)?\\z/`.\nInexact literals are rounded to the nearest representable `Float64`, ties-to-even.\n\nDoes not support infinity and not-a-number.\n\n```\nHexFloat.to_f64(\"0x12.34p+5\")      # => 582.5\nHexFloat.to_f64(\"-0x0.555p-2_f64\") # => -0.08331298828125\n```","summary":"<p>Converts a hexadecimal floating-point literal to a <code>Float64</code>.</p>","abstract":false,"args":[{"name":"str","doc":null,"default_value":"","external_name":"str","restriction":"String"}],"args_string":"(str : String) : Float64","args_html":"(str : String) : Float64","location":{"filename":"src/hexfloat.cr","line_number":252,"url":"https://github.com/HertzDevil/hexfloat.cr/blob/4f17429f5d7da13812e14370f9bbaf4171ed3063/src/hexfloat.cr#L252"},"def":{"name":"to_f64","args":[{"name":"str","doc":null,"default_value":"","external_name":"str","restriction":"String"}],"double_splat":null,"splat_index":null,"yields":null,"block_arg":null,"return_type":"Float64","visibility":"Public","body":"Converter(Float64, UInt64).to_f(str)"}},{"html_id":"to_s(io:IO,num:Float64):Nil-class-method","name":"to_s","doc":"Writes *num* to the given `IO` as a hexadecimal floating-point literal.","summary":"<p>Writes <em>num</em> to the given <code>IO</code> as a hexadecimal floating-point literal.</p>","abstract":false,"args":[{"name":"io","doc":null,"default_value":"","external_name":"io","restriction":"IO"},{"name":"num","doc":null,"default_value":"","external_name":"num","restriction":"Float64"}],"args_string":"(io : IO, num : Float64) : Nil","args_html":"(io : IO, num : Float64) : Nil","location":{"filename":"src/hexfloat.cr","line_number":285,"url":"https://github.com/HertzDevil/hexfloat.cr/blob/4f17429f5d7da13812e14370f9bbaf4171ed3063/src/hexfloat.cr#L285"},"def":{"name":"to_s","args":[{"name":"io","doc":null,"default_value":"","external_name":"io","restriction":"IO"},{"name":"num","doc":null,"default_value":"","external_name":"num","restriction":"Float64"}],"double_splat":null,"splat_index":null,"yields":null,"block_arg":null,"return_type":"Nil","visibility":"Public","body":"Converter(Float64, UInt64).to_s(io, num)"}},{"html_id":"to_s(io:IO,num:Float32):Nil-class-method","name":"to_s","doc":"Writes *num* to the given `IO` as a hexadecimal floating-point literal.","summary":"<p>Writes <em>num</em> to the given <code>IO</code> as a hexadecimal floating-point literal.</p>","abstract":false,"args":[{"name":"io","doc":null,"default_value":"","external_name":"io","restriction":"IO"},{"name":"num","doc":null,"default_value":"","external_name":"num","restriction":"Float32"}],"args_string":"(io : IO, num : Float32) : Nil","args_html":"(io : IO, num : Float32) : Nil","location":{"filename":"src/hexfloat.cr","line_number":303,"url":"https://github.com/HertzDevil/hexfloat.cr/blob/4f17429f5d7da13812e14370f9bbaf4171ed3063/src/hexfloat.cr#L303"},"def":{"name":"to_s","args":[{"name":"io","doc":null,"default_value":"","external_name":"io","restriction":"IO"},{"name":"num","doc":null,"default_value":"","external_name":"num","restriction":"Float32"}],"double_splat":null,"splat_index":null,"yields":null,"block_arg":null,"return_type":"Nil","visibility":"Public","body":"Converter(Float32, UInt32).to_s(io, num)"}},{"html_id":"to_s(num:Float64):String-class-method","name":"to_s","doc":"Returns the hexadecimal floating-point literal for the given *num*.\n\nReturns `Infinity` for infinity, `NaN` for not-a-number.\n\n```\nHexFloat.to_s(6.125)    # => \"0x1.88p+2\"\nHexFloat.to_s(-1.0 / 3) # => \"-0x1.5555555555555p-2\"\n```","summary":"<p>Returns the hexadecimal floating-point literal for the given <em>num</em>.</p>","abstract":false,"args":[{"name":"num","doc":null,"default_value":"","external_name":"num","restriction":"Float64"}],"args_string":"(num : Float64) : String","args_html":"(num : Float64) : String","location":{"filename":"src/hexfloat.cr","line_number":297,"url":"https://github.com/HertzDevil/hexfloat.cr/blob/4f17429f5d7da13812e14370f9bbaf4171ed3063/src/hexfloat.cr#L297"},"def":{"name":"to_s","args":[{"name":"num","doc":null,"default_value":"","external_name":"num","restriction":"Float64"}],"double_splat":null,"splat_index":null,"yields":null,"block_arg":null,"return_type":"String","visibility":"Public","body":"String.build(24) do |io|\n  to_s(io, num)\nend"}},{"html_id":"to_s(num:Float32):String-class-method","name":"to_s","doc":"Returns the hexadecimal floating-point literal for the given *num*.\n\nReturns `Infinity` for infinity, `NaN` for not-a-number.\n\n```\nHexFloat.to_s(1.111_f32)  # => \"0x1.1c6a7ep+0\"\nHexFloat.to_s(-1_f32 / 3) # => \"-0x1.555556p-2\"\n```","summary":"<p>Returns the hexadecimal floating-point literal for the given <em>num</em>.</p>","abstract":false,"args":[{"name":"num","doc":null,"default_value":"","external_name":"num","restriction":"Float32"}],"args_string":"(num : Float32) : String","args_html":"(num : Float32) : String","location":{"filename":"src/hexfloat.cr","line_number":315,"url":"https://github.com/HertzDevil/hexfloat.cr/blob/4f17429f5d7da13812e14370f9bbaf4171ed3063/src/hexfloat.cr#L315"},"def":{"name":"to_s","args":[{"name":"num","doc":null,"default_value":"","external_name":"num","restriction":"Float32"}],"double_splat":null,"splat_index":null,"yields":null,"block_arg":null,"return_type":"String","visibility":"Public","body":"String.build(16) do |io|\n  to_s(io, num)\nend"}}],"constructors":[],"instance_methods":[],"macros":[{"html_id":"to_f(str)-macro","name":"to_f","doc":"Converts a hexadecimal floating-point literal to a `Float32` if it ends with\n`f32`, a `Float64` otherwise.\n\n*str* must be a string literal. The return type is never a union.","summary":"<p>Converts a hexadecimal floating-point literal to a <code>Float32</code> if it ends with <code>f32</code>, a <code>Float64</code> otherwise.</p>","abstract":false,"args":[{"name":"str","doc":null,"default_value":"","external_name":"str","restriction":""}],"args_string":"(str)","args_html":"(str)","location":{"filename":"src/hexfloat.cr","line_number":275,"url":"https://github.com/HertzDevil/hexfloat.cr/blob/4f17429f5d7da13812e14370f9bbaf4171ed3063/src/hexfloat.cr#L275"},"def":{"name":"to_f","args":[{"name":"str","doc":null,"default_value":"","external_name":"str","restriction":""}],"double_splat":null,"splat_index":null,"block_arg":null,"visibility":"Public","body":"    \n{% unless str.is_a?(StringLiteral)\n  raise(\"`str` must be a StringLiteral, not #{str.class_name}\")\nend %}\n\n    \n{% if str.ends_with?(\"f32\") %}\n      ::HexFloat.to_f32({{ str }})\n    {% else %}\n      ::HexFloat.to_f64({{ str }})\n    {% end %}\n\n  \n"}}],"types":[]}]}})