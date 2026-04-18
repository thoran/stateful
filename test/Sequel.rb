# test/Sequel.rb

test_dir = File.dirname(File.expand_path(__FILE__))
sequel_specs = Dir[File.join(test_dir, 'Sequel', '**', '*.rb')]
sequel_specs.each{|spec| require spec}
