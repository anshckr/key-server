require 'securerandom'

class KeysServer
  def initialize
    @max_num_of_keys = 5
    @expire_after = 300 # automatically expire after 300s
    @release_after = 60 # release if blocked
    @key_pool = { } # pool of available keys
    @assigned_keys = { }
  end

  def generate_keys
    while @key_pool.size < @max_num_of_keys
      # generate random key
      random_key = SecureRandom.urlsafe_base64
      @key_pool[random_key] = {
        last_update: Time.now.to_i
      }
    end
    @key_pool
  end

  def available_keys
  	@key_pool
  end

  def assigned_keys
  	@assigned_keys
  end

  def get_key
    key = @key_pool.keys.first
    @key_pool.delete(key)
    @assigned_keys[key] = {
      blocked_at: Time.now.to_i,
    }
    key
  end

  def delete_key(key)
    @key_pool.delete(key)
    @assigned_keys.delete(key)
    key
  end

  def unblock_key(key)
    @assigned_keys.delete(key)
    @key_pool[key] = {
      last_update: Time.now.to_i
    }
    key
  end

  def live(key)
    if @key_pool.key?(key)
      @key_pool[key] = {
        last_update: Time.now.to_i
      }
    end
    key
  end

  def monitor_keys
    while true do
      sleep 1

      @key_pool.each do |key, val|
        if Time.now.to_i - @key_pool[key][:last_update] >= @expire_after
          @key_pool.delete(key)
        end
      end

      @assigned_keys.each do |key, val|
        if Time.now.to_i - @assigned_keys[key][:blocked_at] >= @release_after
          @assigned_keys.delete(key)
          @key_pool[key] = {
            last_update: Time.now.to_i,
          }
        end
      end
    end
  end
end
