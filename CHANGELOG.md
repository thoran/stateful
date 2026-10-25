# stateful/CHANGELOG.md

## 20261025

2.5.0: Raise Stateful::InvalidTransition for an event with no transition from the current state.

1. + lib/Stateful/InvalidTransition.rb: Stateful::InvalidTransition, a StandardError carrying event_name and state_name.
2. + test/Poro/WithInvalidEvent.rb, test/ActiveRecord/WithInvalidEvent.rb, test/Sequel/WithInvalidEvent.rb: an event with no transition, from a non-final state, from a final state and in a named machine, raises Stateful::InvalidTransition and leaves the state, persisted or not, as it was.
3. ~ Stateful::ClassMethods#define_event_method: the event method raises Stateful::InvalidTransition where the current state has no transition for the event. On Poro the state returned to the initial state, and on ActiveRecord and Sequel the attribute setter raised NoMethodError.
4. ~ lib/Stateful/ClassMethods.rb: + require_relative './InvalidTransition'
5. ~ mruby/smoke_tests.rb: + 6. Invalid transitions.
6. ~ README.md: + 9. Events with no transition from the current state.
7. ~ TODO: the 20150117 item on raising errors for improper state changes notes 2.5.0.
8. ~ Stateful::VERSION: /2.4.2/2.5.0/

2.4.2: Rewrite the CHANGELOG in the form changelogger writes.

1. ~ CHANGELOG.md: a `## YYYYMMDD` heading per day, under which each release is `x.y.z: summary` followed by numbered items each marked +, - or ~, in place of a heading per release and a section per kind of change; `\_` and `\*` lose their backslashes. 0.14.10, dated 20150207 and 20200331, goes under 20200331, its release.
2. ~ test/VERSION.rb: "matches the newest entry in the CHANGELOG" reads the version from the first `x.y.z:` line.
3. ~ Stateful::VERSION: /2.4.1/2.4.2/

2.4.1: ~ test: /lib\/stateful\//lib\/Stateful\// where it names the directory, for case-sensitive filesystems; ~ README.md: /thoran\/Stateful/thoran\/stateful/ in the fork link.

1. ~ test/Poro, test/ActiveRecord and test/Sequel: WithPersistenceSpecificExtend.rb and WithPersistenceSpecificExtendAndStatefulBlock.rb: /'..\/..\/lib\/stateful\/'/'..\/..\/lib\/Stateful\/'/. 2.4.0 lowercased the directory along with lib/Stateful.rb, and lib/stateful/ is found only where the filesystem ignores case.
2. ~ README.md: /thoran\/Stateful/thoran\/stateful/ in the Contributing fork link, the repository having been renamed.
3. ~ Stateful::VERSION: /2.4.0/2.4.1/


## 20260912

2.4.0: lib/Stateful.rb --> lib/stateful.rb

1. ~ lib/Stateful.rb --> lib/stateful.rb
2. ~ test: /..\/lib\/Stateful\/..\/lib/stateful\/
3. ~ Stateful::VERSION: /2.3.7/2.4.0/

2.3.7: ~ the requires: /'a\/b'/'.\/a\/b'/; - the blank line above each closing end.

1. ~ lib and test: 17 require_relative lines gain the ./ prefix. The estate writes it that way in 160 of its 210 require_relative lines and in 22 of its 28 repositories, and this repository was one of the six which did not. The two forms resolve identically, require_relative reading the path against the calling file's directory either way.
2. ~ Stateful::VERSION: /2.3.6/2.3.7/

2.3.6: ~ .gitignore: + current default contents

1. ~ .gitignore: 3 lines --> the standard 47, covering gem builds, bundler, RDoc and YARD output, .DS_Store, editor files and coverage output. What was there was *.gem, Gemfile.lock and .claude.
2. ~ Stateful::VERSION: /2.3.5/2.3.6/

2.3.5: ~ the requires: /File.join('a', 'b')/'a\/b'/; - the blank line inside each class and module.

1. ~ lib and test: 7 requires read `File.join` over two string literals, which returns the same string the literal would: File.join joins with File::SEPARATOR, and that is "/" on every platform Ruby runs on, Windows included, File::ALT_SEPARATOR being untouched by it. So it conferred no portability and cost a `git grep` for the path it names.
2. ~ lib and test: - 11 blank lines, each immediately after a class or module line and nothing else.
3. ~ Stateful::VERSION: /2.3.4/2.3.5/


## 20260910

2.3.4: ~ lib/Stateful.rb: + require_relative File.join('Stateful', 'VERSION'); + test/VERSION.rb

1. + test/VERSION.rb: that Stateful::VERSION is a string, that it is three numbers separated by dots, and that it matches the newest entry in the changelog. Modelled on moby's, which is where the convention comes from. The test loads the library rather than VERSION.rb, which is the whole of its value: run against v2.3.3 it fails with "uninitialized constant Stateful::VERSION".
2. ~ lib/Stateful.rb: + `require_relative File.join('Stateful', 'VERSION')`. The file has been present and unreached, so `require 'stateful.rb'` left Stateful::VERSION undefined and the gemspec was the only thing loading it.
3. ~ test/Stateful.rb: + `require_relative 'VERSION'`, the runner globbing only the three persistence directories.
4. ~ Stateful::VERSION: /2.3.3/2.3.4/


## 20260822

2.3.3: + LICENSE, and correct the README.

1. + LICENSE: the MIT text, copyright 2014-2026 thoran. The gemspec has declared MIT while the repository carried no licence text at all.
2. + README.md: a License section, saying MIT, last.
3. ~ stateful.rb.gemspec: + 'LICENSE' to spec.files, so the gem carries what the declaration claims.
4. ~ README.md: /thoran\/Stateful/thoran\/stateful/ in the mruby install line, the repository having been renamed.
5. ~ README.md: /### 6. Multiple state machines per class/### 8. Multiple state machines per class/, the sequence having run 1 to 7 and then 6 again.
6. ~ lib/Stateful/VERSION.rb: /2.3.2/2.3.3/


## 20260418

2.3.2: Add Sequel examples to README.

1. ~ README.md: + Sequel examples (sections 5 and 6), updated description to include Sequel, renumbered remaining sections.
2. ~ lib/Stateful/VERSION.rb: /2.3.1/2.3.2/

2.3.1: Use require_relative in tests.

1. ~ test/ActiveRecord/*.rb:
  - /require 'Stateful'/require_relative '../../lib/Stateful'/
  - /require 'Stateful/ActiveRecord'/require_relative '../../lib/Stateful/ActiveRecord'/
  (Ensures tests always run against the adjacent lib, not an installed gem.)
2. ~ test/Poro/*.rb:
  - /require 'Stateful'/require_relative '../../lib/Stateful'/
  - /require 'Stateful/Poro'/require_relative '../../lib/Stateful/Poro'/
3. ~ test/Sequel/*.rb:
  - /require 'Stateful'/require_relative '../../lib/Stateful'/
  - /require 'Stateful/Sequel'/require_relative '../../lib/Stateful/Sequel'/
4. ~ test/Stateful.rb: - $LOAD_PATH manipulation (no longer needed with require_relative).
5. ~ lib/Stateful/VERSION.rb: /2.3.0/2.3.1/

2.3.0: Extract shared class methods.

1. ~ lib/Stateful/ClassMethods.rb: + shared adapter methods extracted from Poro::ClassMethods, ActiveRecord::ClassMethods, Sequel::ClassMethods. All adapters now delegate to stateful_attribute_name_for_machine.
  - define_named_machine_methods
  - define_event_method
  - define_status_predicate_method
  - define_next_state_method
  - define_transitions_method
  - define_initial_stateQ_method
  - define_final_stateQ_method
2. ~ lib/Stateful/ActiveRecord/ClassMethods.rb:
  - Extracted shared adapter methods to Stateful::ClassMethods.
  - /column_name_for_machine/stateful_attribute_name_for_machine/
3. ~ lib/Stateful/Poro/ClassMethods.rb: Extracted shared adapter methods to Stateful::ClassMethods.
  - Extracted shared adapter methods to Stateful::ClassMethods.
  - /variable_name_for_machine/stateful_attribute_name_for_machine/
4. ~ lib/Stateful/Sequel/ClassMethods.rb: Extracted shared adapter methods to Stateful::ClassMethods.
  - Extracted shared adapter methods to Stateful::ClassMethods.
  - /column_name_for_machine/stateful_attribute_name_for_machine/
5. ~ lib/Stateful/VERSION.rb: /2.2.0/2.3.0/

2.2.0: Add Sequel support.

1. + lib/Stateful/Sequel.rb: Sequel adapter module, mirroring Stateful::ActiveRecord.
2. + lib/Stateful/Sequel/ClassMethods.rb: Sequel-specific class methods using self[:column] / self[:column]= for persistence.
3. + test/Sequel/test_helper.rb: Sequel test helper using in-memory SQLite.
4. + test/Sequel.rb: Sequel test runner.
5. + test/Sequel/WithPersistenceNonSpecificExtend.rb
6. + test/Sequel/WithPersistenceNonSpecificExtendAndStatefulBlock.rb
7. + test/Sequel/WithPersistenceSpecificExtend.rb
8. + test/Sequel/WithPersistenceSpecificExtendAndStatefulBlock.rb
9. + test/Sequel/WithInitialStateBlock.rb
10. + test/Sequel/WithColumnName.rb
11. + test/Sequel/WithMultipleFinalStates.rb
12. + test/Sequel/WithMultipleStateMachines.rb
13. + test/Sequel/WithMultipleStateMachinesAndStatefulBlock.rb
14. + test/Sequel/WithExplicitDeterministicEventOrdering.rb
15. + test/Sequel/WithExplicitNonDeterministicEventOrdering.rb
16. + test/Sequel/WithExplicitGlobalNonDeterministicEventOrdering.rb
17. + test/Sequel/WithExplicitGlobalNonDeterministicEventOrderingAndInitialStateBlock.rb
18. ~ lib/Stateful.rb: Auto-detect Sequel::Model in Stateful.extended, between ActiveRecord and Poro.
19. ~ test/Stateful.rb: + Sequel specs; - $LOAD_PATH.unshift(test_dir) to avoid case-insensitive collision between test/Sequel.rb and require 'sequel'.
20. ~ stateful.rb.gemspec: + sequel dev dependency; update description to include Sequel.
21. ~ lib/Stateful/VERSION.rb: /2.1.0/2.2.0/


## 20260412

2.1.0: Add mRuby support.

1. + mrbgem.rake: mrbgem specification with spec.rbfiles pointing at lib/ directly.
2. + mruby/stub_require_relative.rb: Stub to silence require_relative calls at mRuby build time.
3. + mruby/smoke_test.rb: Smoke test for mRuby compatibility.
4. + TODO (See notes.txt.)
5. - CHANGELOG.txt as it was left empty after creating CHANGELOG.md.
6. - notes.txt (Now TODO.)
7. ~ lib/Stateful.rb: + Object.const_defined?(:ActiveRecord) for mRuby compatibility. In mRuby defined?() raises NameError instead of returning nil as with CRuby.
8. ~ lib/Stateful/VERSION.rb: /2.0.0/2.1.0/


## 20260216

2.0.0: Allow multiple state machines per class.

1. + Stateful::ClassMethods#state_machines: For indexing named `StateMachine` instances.
2. + Stateful::ClassMethods#state_machine
3. + Poro::ClassMethods#define_named_machine_methods
4. + ActiveRecord::ClassMethods#define_named_machine_methods
5. + StateMachine accepts parameter for `global_non_deterministic_event_ordering
6. + ~/test/ActiveRecord/test_helper.rb
7. - StateMachine#stateful
8. ~ Stateful::ClassMethods#stateful: Use class_eval instead of delegating to StateMachine#stateful, which is now removed.
9. ~ /Stateful::States/Stateful::StateMachine/
10. ~ /stateful_states/stateful_state_machine/
11. ~ Test infrastructure migrated from PostgreSQL to SQLite (in-memory)
12. ~ stateful.rb.gemspec: /pg/sqlite3/
13. ~ Stateful::StateMachine#final_states: final_state?, final_states? weren't being defined.
14. ~ lib/Stateful/VERSION.rb: /1.0.2/2.1.0/

1.0.2: Fix non-deterministic event ordering.

1. ~ Stateful::State#non_deterministic_event_ordering?: Fixed logic bug where (@options[:deterministic] && !@options[:deterministic])  always evaluated to false.
2. ~ Stateful::States#global_non_deterministic_event_ordering?: Same fix as above.
3. ~ Stateful::State: /shuffle/shuffle!/non-deterministic ordering actually mutates the transitions array.
4. ~ Stateful::State: Removed require_relative for lib/Array/shuffle.rb.
5. ~ test/ActiveRecord/WithPersistenceSpecificExtend.rb: Fixed delete_all guard to check 'active_record_machine2s' instead of 'active_record_machine1s'.
6. ~ test/ActiveRecord/WithMultipleFinalStates.rb: Fixed comment header (was Poro/WithMultipleFinalStates.rb).
7. ~ test/Poro/WithVariableName.rb: Fixed comment header (was ActiveRecord/WithVariableName.rb).
8. ~ test/Poro/WithExplicitNonDeterministicEventOrdering.rb: Changed transition order assertions to use must_include instead of must_equal.
9. ~ test/ActiveRecord/WithExplicitNonDeterministicEventOrdering.rb: Same as above.
10. ~ test/ActiveRecord/WithExplicitGlobalNonDeterministicEventOrdering.rb: Same as above.
11. ~ test/ActiveRecord/WithExplicitGlobalNonDeterministicEventOrderingAndInitialStateBlock.rb: Same as above.
12. ~ lib/Stateful/VERSION.rb: /1.0.1/1.0.2/
13. - Array#shuffle: Use stdlib.

1.0.1: Fix date and version.

1. ~ stateful.rb.gemspec: Insert the correct date.
2. ~ lib/Stateful/VERSION.rb: /1.0.0/1.0.1/

1.0.0: Version number bump to 1.0.

1. ~ lib/Stateful/VERSION.rb: /0.14.12/1.0.0/

0.14.12: Change file mode on lib/Array/shuffle.rb.

1. ~ lib/Array/shuffle.rb: File mode change to read-only from being executable.
2. ~ lib/Stateful/VERSION.rb: /0.14.11/0.14.12/


## 20200419

0.14.11: Fix copypasta error in README.md.

1. ~ README.md: Fixed copypasta error in Installation section (was 'git.rb', now 'stateful.rb')
2. ~ lib/Stateful/VERSION.rb: /0.14.10/0.14.11/


## 20200331

0.14.10: Allow Poro::ClassMethods to handle its own initialisation when extended.

1. + I finally implemented a change which I'd had sitting in a file never committed named shouldgetthisworking.rb since 2015-02-07 which entails moving the instance method generation methods from each of the application-specific files (lib/Poro.rb and lib/ActiveRecord.rb) to the application-specific class methods files (lib/Poro/ClassMethods.rb and lib/ActiveRecord/ClassMethods.rb).
2. + README.md
3. + CHANGES.txt
4. ~ .gitignore: + *.gem
5. ~ lib/Stateful/VERSION.rb: /0.14.9/0.14.10/
6. ~ stateful.rb.gemspec to reflect the updated version
