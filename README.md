# RubyCrypt
Scanner for required gems & their reverse dependencies in a Ruby Project
with a bundler Gemfile

## Installation
```bash
bundle config set deployment true
bundle install
```

## Usage
1. Navigate to the root directory of the Ruby project (which includes the `Gemfile`)
2. Run 
```bash
bundle exec ruby PATH_TO/rubycrypt.rb [SCAN_DIR] [EXPORT_DIR] [CRYPTO_GEMS]
```
- parameters are optional, default values can be configured in `rubycrypt.rb`
- outputs will be written to `EXPORT_DIR/YYYY-MM-DDTHH-MM-SS` in JSON and Binary Format

### Example
```bash
bundle exec ruby PATH_TO/rubycrypt.rb ./lib /home/user/Desktop openssl ed25519 lockbox
```


### Analysis of output
1. Navigate to the RubyCrypt directory
2. run `irb`
3. `load 'analysis.rb'`
4. Enter timestamp of output directory
5. Global variables for analysis are 
```ruby
$config
$dependency_chains
$requirements
$filtered_requirements
$errors
$not_in_vendor_directory
```

To just output basic statistics about the output, run 
```bash
ruby analysis.rb
```
from the RubyCrypt directory and enter the output directories timestamp.