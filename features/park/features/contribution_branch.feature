Feature: parking a contribution branch

  Background:
    Given the current branch is a contribution branch "branch"
    And an uncommitted file
    When I run "git-town park"

  Scenario: result
    Then it runs no commands
    And the current branch is still "branch"
    And branch "branch" is now parked
    And there are now no contribution branches
    And the uncommitted file still exists

  Scenario: undo
    When I run "git-town undo"
    Then it runs the commands
      | BRANCH | COMMAND       |
      | branch | git add -A    |
      |        | git stash     |
      |        | git stash pop |
    And the current branch is still "branch"
    And branch "branch" is now a contribution branch
    And there are now no parked branches
    And the uncommitted file still exists
