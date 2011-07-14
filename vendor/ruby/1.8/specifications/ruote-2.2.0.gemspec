# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{ruote}
  s.version = "2.2.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["John Mettraux", "Kenneth Kalmer", "Torsten Schoenebaum"]
  s.date = %q{2011-02-28}
  s.description = %q{
ruote is an open source Ruby workflow engine
  }
  s.email = ["jmettraux@gmail.com"]
  s.files = ["Rakefile", "lib/ruote/context.rb", "lib/ruote/engine/process_error.rb", "lib/ruote/engine/process_status.rb", "lib/ruote/engine.rb", "lib/ruote/exp/command.rb", "lib/ruote/exp/commanded.rb", "lib/ruote/exp/condition.rb", "lib/ruote/exp/fe_add_branches.rb", "lib/ruote/exp/fe_apply.rb", "lib/ruote/exp/fe_cancel_process.rb", "lib/ruote/exp/fe_command.rb", "lib/ruote/exp/fe_concurrence.rb", "lib/ruote/exp/fe_concurrent_iterator.rb", "lib/ruote/exp/fe_cron.rb", "lib/ruote/exp/fe_cursor.rb", "lib/ruote/exp/fe_define.rb", "lib/ruote/exp/fe_echo.rb", "lib/ruote/exp/fe_equals.rb", "lib/ruote/exp/fe_error.rb", "lib/ruote/exp/fe_filter.rb", "lib/ruote/exp/fe_forget.rb", "lib/ruote/exp/fe_given.rb", "lib/ruote/exp/fe_if.rb", "lib/ruote/exp/fe_inc.rb", "lib/ruote/exp/fe_iterator.rb", "lib/ruote/exp/fe_let.rb", "lib/ruote/exp/fe_listen.rb", "lib/ruote/exp/fe_lose.rb", "lib/ruote/exp/fe_noop.rb", "lib/ruote/exp/fe_once.rb", "lib/ruote/exp/fe_participant.rb", "lib/ruote/exp/fe_redo.rb", "lib/ruote/exp/fe_ref.rb", "lib/ruote/exp/fe_registerp.rb", "lib/ruote/exp/fe_reserve.rb", "lib/ruote/exp/fe_restore.rb", "lib/ruote/exp/fe_save.rb", "lib/ruote/exp/fe_sequence.rb", "lib/ruote/exp/fe_set.rb", "lib/ruote/exp/fe_subprocess.rb", "lib/ruote/exp/fe_that.rb", "lib/ruote/exp/fe_undo.rb", "lib/ruote/exp/fe_unregisterp.rb", "lib/ruote/exp/fe_wait.rb", "lib/ruote/exp/flowexpression.rb", "lib/ruote/exp/iterator.rb", "lib/ruote/exp/merge.rb", "lib/ruote/exp/ro_attributes.rb", "lib/ruote/exp/ro_filters.rb", "lib/ruote/exp/ro_persist.rb", "lib/ruote/exp/ro_variables.rb", "lib/ruote/fei.rb", "lib/ruote/id/mnemo_wfid_generator.rb", "lib/ruote/id/wfid_generator.rb", "lib/ruote/log/default_history.rb", "lib/ruote/log/pretty.rb", "lib/ruote/log/storage_history.rb", "lib/ruote/log/test_logger.rb", "lib/ruote/log/wait_logger.rb", "lib/ruote/part/block_participant.rb", "lib/ruote/part/engine_participant.rb", "lib/ruote/part/local_participant.rb", "lib/ruote/part/no_op_participant.rb", "lib/ruote/part/null_participant.rb", "lib/ruote/part/smtp_participant.rb", "lib/ruote/part/storage_participant.rb", "lib/ruote/part/template.rb", "lib/ruote/participant.rb", "lib/ruote/reader/ruby_dsl.rb", "lib/ruote/reader/xml.rb", "lib/ruote/reader.rb", "lib/ruote/receiver/base.rb", "lib/ruote/storage/base.rb", "lib/ruote/storage/composite_storage.rb", "lib/ruote/storage/fs_storage.rb", "lib/ruote/storage/hash_storage.rb", "lib/ruote/svc/dispatch_pool.rb", "lib/ruote/svc/dollar_sub.rb", "lib/ruote/svc/error_handler.rb", "lib/ruote/svc/expression_map.rb", "lib/ruote/svc/participant_list.rb", "lib/ruote/svc/tracker.rb", "lib/ruote/svc/treechecker.rb", "lib/ruote/tree_dot.rb", "lib/ruote/util/filter.rb", "lib/ruote/util/hashdot.rb", "lib/ruote/util/look.rb", "lib/ruote/util/lookup.rb", "lib/ruote/util/misc.rb", "lib/ruote/util/ometa.rb", "lib/ruote/util/serializer.rb", "lib/ruote/util/subprocess.rb", "lib/ruote/util/time.rb", "lib/ruote/util/tree.rb", "lib/ruote/version.rb", "lib/ruote/worker.rb", "lib/ruote/workitem.rb", "lib/ruote.rb", "test/bm/ci.rb", "test/bm/ici.rb", "test/bm/juuman.rb", "test/bm/launch_bench.rb", "test/bm/load_26c.rb", "test/bm/mega.rb", "test/bm/seq_thousand.rb", "test/bm/t.rb", "test/functional/base.rb", "test/functional/concurrent_base.rb", "test/functional/crunner.rb", "test/functional/ct_0_concurrence.rb", "test/functional/ct_1_iterator.rb", "test/functional/ct_2_cancel.rb", "test/functional/eft_0_process_definition.rb", "test/functional/eft_10_cancel_process.rb", "test/functional/eft_11_wait.rb", "test/functional/eft_12_listen.rb", "test/functional/eft_13_iterator.rb", "test/functional/eft_14_cursor.rb", "test/functional/eft_15_loop.rb", "test/functional/eft_16_if.rb", "test/functional/eft_17_equals.rb", "test/functional/eft_18_concurrent_iterator.rb", "test/functional/eft_19_reserve.rb", "test/functional/eft_1_echo.rb", "test/functional/eft_20_save.rb", "test/functional/eft_21_restore.rb", "test/functional/eft_22_noop.rb", "test/functional/eft_23_apply.rb", "test/functional/eft_24_add_branches.rb", "test/functional/eft_25_command.rb", "test/functional/eft_26_error.rb", "test/functional/eft_27_inc.rb", "test/functional/eft_28_once.rb", "test/functional/eft_29_cron.rb", "test/functional/eft_2_sequence.rb", "test/functional/eft_30_ref.rb", "test/functional/eft_31_registerp.rb", "test/functional/eft_32_lose.rb", "test/functional/eft_33_let.rb", "test/functional/eft_34_given.rb", "test/functional/eft_35_filter.rb", "test/functional/eft_3_participant.rb", "test/functional/eft_4_set.rb", "test/functional/eft_5_subprocess.rb", "test/functional/eft_6_concurrence.rb", "test/functional/eft_7_forget.rb", "test/functional/eft_8_undo.rb", "test/functional/eft_9_redo.rb", "test/functional/ft_0_worker.rb", "test/functional/ft_10_dollar.rb", "test/functional/ft_11_recursion.rb", "test/functional/ft_12_launchitem.rb", "test/functional/ft_13_variables.rb", "test/functional/ft_14_re_apply.rb", "test/functional/ft_15_timeout.rb", "test/functional/ft_16_participant_params.rb", "test/functional/ft_17_conditional.rb", "test/functional/ft_18_kill.rb", "test/functional/ft_19_alias.rb", "test/functional/ft_1_process_status.rb", "test/functional/ft_20_storage_participant.rb", "test/functional/ft_21_forget.rb", "test/functional/ft_22_process_definitions.rb", "test/functional/ft_23_load_defs.rb", "test/functional/ft_24_block_participant.rb", "test/functional/ft_25_receiver.rb", "test/functional/ft_26_participant_rtimeout.rb", "test/functional/ft_27_var_indirection.rb", "test/functional/ft_28_null_noop_participants.rb", "test/functional/ft_29_part_template.rb", "test/functional/ft_2_errors.rb", "test/functional/ft_30_smtp_participant.rb", "test/functional/ft_31_part_blocking.rb", "test/functional/ft_33_participant_subprocess_priority.rb", "test/functional/ft_34_cursor_rewind.rb", "test/functional/ft_35_add_service.rb", "test/functional/ft_36_storage_history.rb", "test/functional/ft_37_default_history.rb", "test/functional/ft_38_participant_more.rb", "test/functional/ft_39_wait_for.rb", "test/functional/ft_3_participant_registration.rb", "test/functional/ft_40_wait_logger.rb", "test/functional/ft_41_participants.rb", "test/functional/ft_42_storage_copy.rb", "test/functional/ft_43_participant_on_reply.rb", "test/functional/ft_44_var_participant.rb", "test/functional/ft_45_participant_accept.rb", "test/functional/ft_46_launch_single.rb", "test/functional/ft_47_wfid_generator.rb", "test/functional/ft_48_lose.rb", "test/functional/ft_49_engine_on_error.rb", "test/functional/ft_4_cancel.rb", "test/functional/ft_50_engine_config.rb", "test/functional/ft_51_misc.rb", "test/functional/ft_52_case.rb", "test/functional/ft_53_engine_on_terminate.rb", "test/functional/ft_54_patterns.rb", "test/functional/ft_55_engine_participant.rb", "test/functional/ft_56_filter_attribute.rb", "test/functional/ft_5_on_error.rb", "test/functional/ft_6_on_cancel.rb", "test/functional/ft_7_tags.rb", "test/functional/ft_8_participant_consumption.rb", "test/functional/ft_9_subprocesses.rb", "test/functional/restart_base.rb", "test/functional/rt_0_wait.rb", "test/functional/rt_1_listen.rb", "test/functional/rt_2_errors.rb", "test/functional/rt_3_once.rb", "test/functional/rt_4_cron.rb", "test/functional/rt_5_timeout.rb", "test/functional/rtest.rb", "test/functional/storage_helper.rb", "test/functional/test.rb", "test/functional/vertical.rb", "test/path_helper.rb", "test/test.rb", "test/test_helper.rb", "test/unit/storage.rb", "test/unit/storages.rb", "test/unit/test.rb", "test/unit/ut_0_ruby_reader.rb", "test/unit/ut_11_lookup.rb", "test/unit/ut_13_serializer.rb", "test/unit/ut_14_is_uri.rb", "test/unit/ut_15_util.rb", "test/unit/ut_16_reader.rb", "test/unit/ut_18_engine.rb", "test/unit/ut_19_part_template.rb", "test/unit/ut_1_fei.rb", "test/unit/ut_20_composite_storage.rb", "test/unit/ut_21_participant_list.rb", "test/unit/ut_22_filter.rb", "test/unit/ut_3_wait_logger.rb", "test/unit/ut_4_expmap.rb", "test/unit/ut_5_tree.rb", "test/unit/ut_6_condition.rb", "test/unit/ut_7_workitem.rb", "test/unit/ut_8_tree_to_dot.rb", "test/unit/ut_9_xml_reader.rb", "ruote.gemspec", "CHANGELOG.txt", "CREDITS.txt", "LICENSE.txt", "TODO.txt", "couch_url.txt", "jruby_issue.txt", "phil.txt", "README.rdoc"]
  s.homepage = %q{http://ruote.rubyforge.org}
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{ruote}
  s.rubygems_version = %q{1.4.2}
  s.summary = %q{an open source Ruby workflow engine}

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<sourcify>, ["= 0.4.2"])
      s.add_runtime_dependency(%q<rufus-json>, [">= 0.2.5"])
      s.add_runtime_dependency(%q<rufus-cloche>, [">= 0.1.20"])
      s.add_runtime_dependency(%q<rufus-dollar>, [">= 1.0.4"])
      s.add_runtime_dependency(%q<rufus-mnemo>, [">= 1.1.0"])
      s.add_runtime_dependency(%q<rufus-scheduler>, [">= 2.0.8"])
      s.add_runtime_dependency(%q<rufus-treechecker>, [">= 1.0.4"])
      s.add_development_dependency(%q<rake>, [">= 0"])
      s.add_development_dependency(%q<json>, [">= 0"])
      s.add_development_dependency(%q<builder>, [">= 0"])
      s.add_development_dependency(%q<mailtrap>, [">= 0"])
    else
      s.add_dependency(%q<sourcify>, ["= 0.4.2"])
      s.add_dependency(%q<rufus-json>, [">= 0.2.5"])
      s.add_dependency(%q<rufus-cloche>, [">= 0.1.20"])
      s.add_dependency(%q<rufus-dollar>, [">= 1.0.4"])
      s.add_dependency(%q<rufus-mnemo>, [">= 1.1.0"])
      s.add_dependency(%q<rufus-scheduler>, [">= 2.0.8"])
      s.add_dependency(%q<rufus-treechecker>, [">= 1.0.4"])
      s.add_dependency(%q<rake>, [">= 0"])
      s.add_dependency(%q<json>, [">= 0"])
      s.add_dependency(%q<builder>, [">= 0"])
      s.add_dependency(%q<mailtrap>, [">= 0"])
    end
  else
    s.add_dependency(%q<sourcify>, ["= 0.4.2"])
    s.add_dependency(%q<rufus-json>, [">= 0.2.5"])
    s.add_dependency(%q<rufus-cloche>, [">= 0.1.20"])
    s.add_dependency(%q<rufus-dollar>, [">= 1.0.4"])
    s.add_dependency(%q<rufus-mnemo>, [">= 1.1.0"])
    s.add_dependency(%q<rufus-scheduler>, [">= 2.0.8"])
    s.add_dependency(%q<rufus-treechecker>, [">= 1.0.4"])
    s.add_dependency(%q<rake>, [">= 0"])
    s.add_dependency(%q<json>, [">= 0"])
    s.add_dependency(%q<builder>, [">= 0"])
    s.add_dependency(%q<mailtrap>, [">= 0"])
  end
end
