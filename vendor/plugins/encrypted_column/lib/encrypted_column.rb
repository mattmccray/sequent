require 'crypt/rijndael'
require 'base64'

module EncryptedColumn

  def self.included(klass)
    klass.extend(ClassMethods)
  end
  
  def self.encrypt(value, key, b64=false )
    bf = Crypt::Rijndael.new( key )
    enc = bf.encrypt_string( value.to_s )
    enc = Base64.encode64(enc.to_s) if b64
    enc
  end

  def self.decrypt(value, key, b64=false )
    bf = Crypt::Rijndael.new( key )
    value = Base64.decode64(value) if b64
    bf.decrypt_string( value.to_s )
  end
    
  module ClassMethods
    
    def encrypted_column( name, key, options={} )
      
      define_method "decrypted_#{name}" do
        crypt_key = (key.is_a? Symbol) ? send(key) : key
        EncryptedColumn.decrypt( send(name).to_s, crypt_key )
      end

      define_method "#{name}=" do |value|
        return if value.nil? or value.empty?
        crypt_key = (key.is_a? Symbol) ? send(key) : key
        self[name] = EncryptedColumn.encrypt(value.to_s, crypt_key)
      end
      
#       before_save do |record|
#         crypt_key = (key.is_a? Symbol) ? record.send(key) : key
#         record[name] = EncryptedColumn.encrypt(record[name], crypt_key)
#       end
      
    end
    
  end
  
end

# es = EncryptedColumn.encrypt('test', '!Sequent-Mmmm-Salty!')
# ds = EncryptedColumn.decrypt(es, '!Sequent-Mmmm-Salty!')
# puts "#{es} == #{ds}"

#dv = EncryptedColumn.decrypt( "LO6WF9eLzijmwm3kwZ//sfNu7VREw0m3a1rJ6bL1Oc0=", '!Sequent-Mmmm-Salty!' )
#puts ""
#puts "DV = #{dv}"
