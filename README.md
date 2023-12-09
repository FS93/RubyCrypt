# RubyCrypt
Scanner for required gems & their Reverse Dependencies in a Ruby Project
with a bundler Gemfile

## Usage
1. Navigate to the root directory of the Ruby project (which includes the `Gemfile`)
2. Run 
```bash
bundle exec ruby PATH_TO/rubycrypt.rb [SCAN_DIR] [EXPORT_DIR] [CRYPTO_GEMS]
```
- parameters are optional, default values can be configured in `rubycrypt.rb`
- outputs will be written to `EXPORT_DIR/YYYY-MM-DDTHH-MM-SS` in JSON and Binary Format

### Analysis of output in `irb`
1. Navigate to the output directory
2. run `irb`
3. `require 'PATH_TO/load_marshalled_data.rb'`
4. global variables 
```ruby
$requirements
$filtered_requirements
$errors
$not_in_vendor_directory
```
contain the output

