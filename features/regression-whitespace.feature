Feature: Regression test - whitespace on empty lines

  Scenario: Empty lines shouldn't be indented
    Given I am in a new buffer "test" with the content:
      """
      (defun test ()
      (message \"test\")

      (message \"test\"))
      """
    And I turn on lisp-mode
    And I quietly turn on indentinator-mode
    And I place the cursor before "(defun test "
    When I type " "
    And wait for idle timers
    Then the buffer should contain:
      """
       (defun test ()
         (message \"test\")

         (message \"test\"))
      """
