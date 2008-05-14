require 'test/unit'
require 'active_support'
require File.dirname(__FILE__) + '/../../../../config/boot'
require 'encrypted_column'

class EncryptedColumnTest < Test::Unit::TestCase

  def test_encryption
    test_key = "test-key"
    s = "Hello"
    enc_s = EncryptedColumn.encrypt(s, test_key)
    dec_s = EncryptedColumn.decrypt(enc_s, test_key)
    assert_equal s, dec_s
  end
  
  def test_repeated_encryption
    25.times do
      test_key = "test-key"
      s = "Hello"
      enc_s = EncryptedColumn.encrypt(s, test_key)
      dec_s = EncryptedColumn.decrypt(enc_s, test_key)
      assert_equal s, dec_s
    end
  end
  
end
