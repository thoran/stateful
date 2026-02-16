## 2.0.0
date: 20260216
summary: Allow multiple state machines per class.
-----------------------------------------------------------------------------------------------------------------------

### +
1. Stateful::ClassMethods#state_machines: For indexing named `StateMachine` instances.
2. Stateful::ClassMethods#state_machine
3. Poro::ClassMethods#define_named_machine_methods
4. ActiveRecord::ClassMethods#define_named_machine_methods
5. StateMachine accepts parameter for `global_non_deterministic_event_ordering
6. ~/test/ActiveRecord/test_helper.rb

### -
1. StateMachine#stateful

### ~
1. Stateful::ClassMethods#stateful: Use class_eval instead of delegating to StateMachine#stateful, which is now removed.
2. /Stateful::States/Stateful::StateMachine/
3. /stateful_states/stateful_state_machine/
4. Test infrastructure migrated from PostgreSQL to SQLite (in-memory)
5. stateful.rb.gemspec: /pg/sqlite3/
6. Stateful::StateMachine#final_states: final_state?, final_states? weren't being defined.


## 1.0.2
date: 20260216
summary: Fix non-deterministic event ordering.
(aka The 'Don't try to push out changes while the dog is hassling you to take them for a walk!' Edition)
-----------------------------------------------------------------------------------------------------------------------

### ~
1. Stateful::State#non_deterministic_event_ordering?: Fixed logic bug where (@options[:deterministic] && !@options[:deterministic])  always evaluated to false.
2. Stateful::States#global_non_deterministic_event_ordering?: Same fix as above.
3. Stateful::State: /shuffle/shuffle!/non-deterministic ordering actually mutates the transitions array.
4. Stateful::State: Removed require_relative for lib/Array/shuffle.rb.
5. test/ActiveRecord/WithPersistenceSpecificExtend.rb: Fixed delete_all guard to check 'active_record_machine2s' instead of 'active_record_machine1s'.
6. test/ActiveRecord/WithMultipleFinalStates.rb: Fixed comment header (was Poro/WithMultipleFinalStates.rb).
7. test/Poro/WithVariableName.rb: Fixed comment header (was ActiveRecord/WithVariableName.rb).
8. test/Poro/WithExplicitNonDeterministicEventOrdering.rb: Changed transition order assertions to use must_include instead of must_equal.
9. test/ActiveRecord/WithExplicitNonDeterministicEventOrdering.rb: Same as above.
10. test/ActiveRecord/WithExplicitGlobalNonDeterministicEventOrdering.rb: Same as above.
11. test/ActiveRecord/WithExplicitGlobalNonDeterministicEventOrderingAndInitialStateBlock.rb: Same as above.
12. Stateful::VERSION: /1.0.1/1.0.2/

### -
1. Array#shuffle: Use stdlib.

## 1.0.1
date: 20260216
-----------------------------------------------------------------------------------------------------------------------

### ~
1. stateful.rb.gemspec: Insert the correct date.
2. Stateful::VERSION: /1.0.0/1.0.1/

## 1.0.0
date: 20260216
-----------------------------------------------------------------------------------------------------------------------

### ~
1. Stateful::VERSION: /0.14.12/1.0.0/

## 0.14.12
date: 20260216
-----------------------------------------------------------------------------------------------------------------------

### ~
1. lib/Array/shuffle.rb: File mode change to read-only from being executable.
2. Stateful::VERSION.rb: /0.14.11/0.14.12/

## 0.14.11
date: 20200419
-----------------------------------------------------------------------------------------------------------------------

### ~
1. README.md: Fixed copypasta error in Installation section (was 'git.rb', now 'stateful.rb')
2. Stateful::VERSION: /0.14.10/0.14.11/

## 0.14.10
date: 20150207, 20200331
-----------------------------------------------------------------------------------------------------------------------

### +
1. I finally implemented a change which I'd had sitting in a file never committed named shouldgetthisworking.rb since 2015-02-07 which entails moving the instance method generation methods from each of the application-specific files (lib/Poro.rb and lib/ActiveRecord.rb) to the application-specific class methods files (lib/Poro/ClassMethods.rb and lib/ActiveRecord/ClassMethods.rb).
2. README.md
3. CHANGES.txt

### ~
1. .gitignore: + *.gem
2. Stateful::VERSION.rb
3. stateful.rb.gemspec to reflect the updated version
