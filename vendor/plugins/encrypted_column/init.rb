require 'encrypted_column'
ActiveRecord::Base.send(:include, EncryptedColumn)
