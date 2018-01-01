Feature: Basic indentation

  Scenario: Simple test
    Given I am in buffer "test" with the content:
      """
      (defun test ()
      (message \"test\"))

      (defun test2 ()
      (message \"test2\"))
      """
    And I turn on lisp-mode
    And I quietly turn on indentinator-mode
    And I place the cursor before "(defun test "
    When I type " "
    And wait for idle timers
    Then the buffer should contain:
      """
       (defun test ()
         (message \"test\"))

      (defun test2 ()
        (message \"test2\"))
      """

  Scenario: Test stopping
    Given I am in buffer "test3" with the content:
      """
      (defun test ()
      (message \"test\"))


      (defun test2 ()
      (message \"test2\"))
      """
    And I turn on lisp-mode
    And I quietly turn on indentinator-mode
    And I place the cursor before "(defun test "
    When I type " "
    And wait for idle timers
    Then the buffer should contain:
      """
       (defun test ()
         (message \"test\"))


      (defun test2 ()
      (message \"test2\"))
      """

  Scenario: Simple test2
    Given I am in buffer "test2" with the content:
      """
      (defun test ()
        (message \"test\"))

      (defun test2 ()
        (message \"test2\"))
      """
    And I turn on lisp-mode
    And I quietly turn on indentinator-mode
    And I place the cursor before "(defun test "
    When I type " "
    And wait for idle timers
    And I place the cursor before "(defun test2 "
    When I type " "
    And wait for idle timers
    Then the buffer should contain:
      """
       (defun test ()
         (message \"test\"))

       (defun test2 ()
         (message \"test2\"))
      """
