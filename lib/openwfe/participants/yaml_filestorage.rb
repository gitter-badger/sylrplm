#--
# Copyright (c) 2006-2009, Nicolas Modryzk and John Mettraux, OpenWFE.org
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.
#
# Made in Japan.
#++


require 'find'
require 'yaml'
require 'monitor'
require 'fileutils'

require 'openwfe/utils'
require 'openwfe/service'


module OpenWFE

  #
  # Stores OpenWFEru related objects into yaml encoded files.
  # This storage is meant to look and feel like a Hash.
  #
  # DEPRECATED
  #
  class YamlFileStorage
    include ServiceMixin

    #
    # The root path for this file persistence mecha.
    #
    attr_accessor :basepath

    def initialize (service_name, application_context, path)

      super()

      service_init(service_name, application_context)

      @basepath = get_work_directory + path
      @basepath += '/' if @basepath[-1, 1] != '/'

      FileUtils.makedirs @basepath
    end

    #
    # Stores an object with its FlowExpressionId instance as its key.
    #
    def []= (fei, object)

      #linfo { "[]= #{fei}" }

      fei_path = compute_file_path(fei)

      fei_parent_path = File.dirname(fei_path)

      FileUtils.makedirs(fei_parent_path) \
        unless File.exist?(fei_parent_path)

      File.open(fei_path, 'w') { |file| YAML.dump(object, file) }
    end

    #
    # Deletes the whole storage directory... beware...
    #
    def purge

      FileUtils.remove_dir(@basepath)
    end

    #
    # Checks whether there is an object (expression, workitem) stored
    # for the given FlowExpressionId instance.
    #
    def has_key? (fei)

      File.exist?(compute_file_path(fei))
    end

    #
    # Removes the object (file) stored for the given FlowExpressionId
    # instance.
    #
    def delete (fei)

      fei_path = compute_file_path(fei)

      #ldebug { "delete() for #{fei.to_debug_s} at #{fei_path}" }

      File.delete(fei_path)
    end

    #
    # Actually loads and returns the object for the given
    # FlowExpressionId instance.
    #
    def [] (fei)

      fei_path = compute_file_path(fei)

      if not File.exist?(fei_path)

        ldebug { "[] didn't find file at #{fei_path}" }
        #puts  "[] didn't find file at #{fei_path}"

        return nil
      end

      load_object(fei_path)
    end

    #
    # Returns the count of objects currently stored in this instance.
    #
    def length

      count_objects()
    end

    alias :size :length

    protected

      def load_object (path)

        object = YAML.load_file(path)

        object.application_context = @application_context \
          if object.respond_to?(:application_context=)

        object
      end

      #
      # Returns the number of 'objects' currently in this storage.
      #
      def count_objects

        count = 0

        Find.find(@basepath) do |path|

          next unless File.exist? path
          next if File.stat(path).directory?

          count += 1 if path[-5..-1] == '.yaml'
        end

        count
      end

      #
      # Passes each object path to the given block
      #
      def each_object_path (path=@basepath, &block)

        Find.find(path) do |p|

          next unless File.exist?(p)
          next if File.stat(p).directory?
          #next unless OpenWFE::ends_with(p, '.yaml')
          next if p[-5..-1] != '.yaml'

          #ldebug { "each_object_path() considering #{p}" }
          block.call(p)
        end
      end

      #
      # Passes each object to the given block
      #
      def each_object (&block)

        each_object_path do |path|
          block.call(load_object(path))
        end
      end

      #
      # each_value() is a method from Hash, by providing it here
      # it's easier to disguise a YamlFileStorage as a hash.
      #
      alias :each_value :each_object

      protected

        #
        # Each object is meant to have a unique file path,
        # this method wraps the determination of that path. It has to
        # be provided by extending classes.
        #
        def compute_file_path (object)

          raise NotImplementedError.new
        end

    end

  end
