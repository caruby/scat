require 'redis'

module Scat
  # The session and global key => value cache wrapper.
  class Cache
    # @return [Redis] the Redis cache data store
    # @raise [ScatError] if the cache could not be started
    def datastore
      @redis ||= discover
    end
    
    # Sets the given value to the cache tag set as follows:
    # * If the key is nil, then the cache entry is the tag.
    # * Otherwise, the cache entry is the tag hash entry for the given key.
    # * If the value is nil, then the entry is removed from the cache.
    # * Otherwise, the value is converted to a string, if necessary, and
    #   the cache entry is set to the value.
    #
    # @param [String, Symbol] tag the cache tag 
    # @param value the value to set 
    # @param [String, Symbol, nil] key the cache tag hash key
    def set(tag, value, key=nil)
      if value.nil? then
        key ? datastore.hdel(tag, key) : datastore.rem(tag) 
      else
        key ? datastore.hset(tag, key, value) : datastore.set(tag, value)
      end
    end

     # Adds the given value to the cache tag set. The value is converted to
     # a string, if necessary.
     #
     # @param [String, Symbol] tag the cache tag 
     # @param value the value to add 
     def add(tag, value)
       datastore.zadd(tag, 0, value)
     end
     
    # @param [String, Symbol] tag the cache tag
    # @param [Symbol, nil] the cached tag hash key
    # @return [String, <String>] the matching value or values
    def get(tag, key=nil)
      key ? datastore.hget(tag, key) : datastore.get(tag)
    end
    
    # @param [String, Symbol] tag the cache tag
    # @return [<String>] the matching set
    def get_all(tag)
      datastore.zrange(tag, 0, -1)
    end
    
    private
    
    REDIS_SERVER = File.expand_path('redis-server', File.dirname(__FILE__) + '/../../bin')
    
    REDIS_CONF = File.expand_path('redis.conf', File.dirname(__FILE__) + '/../../conf')
                                      
    # Locates the Redis server on the default Redis port.
    #
    # @return [Redis] the Redis client
    # @raise (see #start)
    def discover
      redis = Redis.current
      redis.ping rescue start(redis)
      redis
    end
    
    # Starts the Redis server on the default Redis port.
    #
    # @param [Redis] the Redis client
    # @raise [ScatError] if the server command could not be executed
    # @raise [Exception] if the server is not reachable
    def start(redis)
      logger.debug { "Scat is starting the Redis cache server..." }
      unless system(REDIS_SERVER, REDIS_CONF) then
        raise ScatError.new("Scat cannot start the Redis cache server.")
      end
      # Ping the server until loaded. 
      3.times do |n|
        begin
          redis.ping
          logger.debug { "Scat started the Redis cache server." }
          return redis
        rescue
          n < 2 ? sleep(0.5) : raise
        end
      end
    end
  end
end
