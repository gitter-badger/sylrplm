#--
# Copyright (c) 2005-2011, John Mettraux, jmettraux@gmail.com
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


module Ruote

  #
  # The tracker service is used by the "listen" expression. This services
  # sees all the msg processed by a worker and triggers any
  # listener interested in a particular msg.
  #
  # Look at the ListenExpression for more details.
  #
  class Tracker

    def initialize(context)

      @context = context

      if @context.worker
        #
        # this is a worker context, DO log
        #
        @context.worker.subscribe(:all, self)
      #else
        #
        # this is not a worker context, no notifications. BUT
        # honour calls to add_tracker/remove_tracker
        #
      end
    end

    # The worker passes all the messages it has to process to the tracker via
    # this method.
    #
    def notify(msg)

      m_error = msg['error']
      m_wfid = msg['wfid'] || (msg['fei']['wfid'] rescue nil)
      m_action = msg['action']

      @context.storage.get_trackers['trackers'].each do |tracker_id, tracker|

        # filter msgs

        t_wfid = tracker['wfid']
        t_action = tracker['action']

        next if t_wfid && t_wfid != m_wfid
        next if t_action && t_action != m_action

        next unless does_match?(msg, tracker['conditions'])

        msg = msg['msg'] if m_action == 'error_intercepted'

        if tracker_id == 'on_error' || tracker_id == 'on_terminate'

          fields = msg['workitem']['fields']

          next if m_action == 'error_intercepted' && fields['__error__']
          next if m_action == 'terminated' && (fields['__error__'] || fields['__terminate__'])
        end

        # prepare and emit/put 'reaction' message

        m = tracker['msg']

        action = m.delete('action')

        m['wfid'] = m_wfid if m['wfid'] == 'replace'
        m['wfid'] ||= @context.wfidgen.generate

        m['workitem'] = msg['workitem'] if m['workitem'] == 'replace'

        if tracker_id == 'on_error' && m_action == 'error_intercepted'
          m['workitem']['fields']['__error__'] = m_error
        elsif tracker_id == 'on_terminate' && m_action == 'terminated'
          m['workitem']['fields']['__terminate__'] = { 'wfid' => m_wfid }
        end

        if m['variables'] == 'compile'
          fexp = Ruote::Exp::FlowExpression.fetch(@context, msg['fei'])
          m['variables'] = fexp ? fexp.compile_variables : {}
        end

        @context.storage.put_msg(action, m)
      end
    end

    # Adds a tracker (usually when a 'listen' expression gets applied).
    #
    def add_tracker(wfid, action, id, conditions, msg)

      doc = @context.storage.get_trackers

      doc['trackers'][id] =
        { 'wfid' => wfid,
          'action' => action,
          'id' => id,
          'conditions' => conditions,
          'msg' => msg }

      r = @context.storage.put(doc)

      add_tracker(wfid, action, id, msg) if r
        # the put failed, have to redo the work
    end

    # Removes a tracker (usually when a 'listen' expression replies to its
    # parent expression or is cancelled).
    #
    def remove_tracker(fei, doc=nil)

      doc ||= @context.storage.get_trackers

      doc['trackers'].delete(Ruote.to_storage_id(fei))

      r = @context.storage.put(doc)

      remove_tracker(fei, r) if r
        # the put failed, have to redo the work
    end

    protected

    def does_match?(msg, conditions)

      return true unless conditions

      conditions.each do |k, v|

        val = msg[k]
        v = Ruote.regex_or_s(v)

        if v.is_a?(String)
          return false unless val && v == val
        else
          return false unless val && v.match(val)
        end
      end

      true
    end
  end
end

