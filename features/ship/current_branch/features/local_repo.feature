Feature: ship a feature branch in a local repo

  Background:
    Given the current branch is a feature branch "feature"
    And my repo does not have an origin
    And the commits
      | BRANCH  | LOCATION | MESSAGE        |
      | feature | local    | feature commit |
    When I run "git-town ship -m 'feature done'"

  Scenario: result
    Then it runs the commands
      | BRANCH  | COMMAND                      |
      | feature | git checkout main            |
      | main    | git merge --squash feature   |
      |         | git commit -m "feature done" |
      |         | git branch -D feature        |
    And the current branch is now "main"
    And the branches are now
      | REPOSITORY | BRANCHES |
      | local      | main     |
    And now these commits exist
      | BRANCH | LOCATION | MESSAGE      |
      | main   | local    | feature done |
    And no branch hierarchy exists now

  Scenario: undo
    When I run "git-town undo"
    Then it runs the commands
      | BRANCH | COMMAND                                       |
      | main   | git reset --hard {{ sha 'Initial commit' }}   |
      |        | git branch feature {{ sha 'feature commit' }} |
      |        | git checkout feature                          |
    And the current branch is now "feature"
    And now the initial commits exist
    And the initial branches and hierarchy exist
