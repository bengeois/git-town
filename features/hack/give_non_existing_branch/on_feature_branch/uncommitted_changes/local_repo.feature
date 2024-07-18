Feature: local repo

  Background:
    Given a Git repo clone
    And the branches
      | NAME     | TYPE    | PARENT | LOCATIONS     |
      | existing | feature | main   | local, origin |
    And the current branch is "existing"
    And my repo does not have an origin
    And the commits
      | BRANCH | LOCATION | MESSAGE     |
      | main   | local    | main commit |
    And an uncommitted file
    When I run "git-town hack new"

  Scenario: result
    Then it runs the commands
      | BRANCH   | COMMAND                  |
      | existing | git add -A               |
      |          | git stash                |
      |          | git checkout -b new main |
      | new      | git stash pop            |
    And the current branch is now "new"
    And the uncommitted file still exists
    And these commits exist now
      | BRANCH | LOCATION | MESSAGE     |
      | main   | local    | main commit |
      | new    | local    | main commit |
    And this lineage exists now
      | BRANCH   | PARENT |
      | existing | main   |
      | new      | main   |

  Scenario: undo
    When I run "git-town undo"
    Then it runs the commands
      | BRANCH   | COMMAND               |
      | new      | git add -A            |
      |          | git stash             |
      |          | git checkout existing |
      | existing | git branch -D new     |
      |          | git stash pop         |
    And the current branch is now "existing"
    And the uncommitted file still exists
    And the initial commits exist
    And this lineage exists now
      | BRANCH   | PARENT |
      | existing | main   |
