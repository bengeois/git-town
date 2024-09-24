Feature: already existing local branch

  Background:
    Given a Git repo with origin
    And the branches
      | NAME     | TYPE    | PARENT | LOCATIONS |
      | existing | feature | main   | local     |
    When I run "git-town hack existing"

  Scenario: result
    Then it runs the commands
      | BRANCH | COMMAND                  |
      | main   | git fetch --prune --tags |
    And it prints the error:
      """
      branch "existing" is already a feature branch
      """
    And the current branch is still "main"
    And the initial branches and lineage exist now

  Scenario: undo
    When I run "git-town undo"
    Then it runs no commands
    And the current branch is still "main"
    And the initial commits exist now
    And the initial branches and lineage exist now
