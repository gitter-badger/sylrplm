#--
# Copyright (c) 2008-2009, John Mettraux, jmettraux@gmail.com
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


#
# A group of users
#
class Group < ActiveRecord::Base
include Models::SylrplmCommon
  has_many :user_groups, :dependent => :delete_all
  has_many :users, :through => :user_groups

  has_many :group_definitions, :dependent => :delete_all
  has_many :definitions, :through => :group_definitions

  #
  # User and Group share this method, which returns login and name respectively
  #
  def system_name
    self.name
  end

  def may_launch_untracked_process?
    self.definitions.detect { |d| d.name == '*untracked*' }
  end

  def may_launch_embedded_process?
    self.definitions.detect { |d| d.name == '*embedded*' }
  end
def self.get_conditions(filter)
    filter=filter.gsub("*","%")
    conditions = ["name LIKE ? ", filter ] unless filter.nil?
  end
  
end

