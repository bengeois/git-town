Feature: handle merge conflicts between feature branch and main branch

  Background:
    Given my repo has the feature branches "alpha", "beta", and "gamma"
    And the commits
      | BRANCH | LOCATION      | MESSAGE            | FILE NAME            | FILE CONTENT        |
      | main   | origin        | main commit        | conflicting_file     | main content        |
      | alpha  | local, origin | alpha commit       | feature1_file        | alpha content       |
      | beta   | local         | local beta commit  | conflicting_file     | local beta content  |
      |        | origin        | origin beta commit | feature2_origin_file | origin beta content |
      | gamma  | origin        | gamma commit       | feature3_file        | gamma content       |
    And I am on the "main" branch
    And my workspace has an uncommitted file
    When I run "git-town sync --all"

  Scenario: result
    Then it runs the commands
      | BRANCH | COMMAND                          |
      | main   | git fetch --prune --tags         |
      |        | git add -A                       |
      |        | git stash                        |
      |        | git rebase origin/main           |
      |        | git checkout alpha               |
      | alpha  | git merge --no-edit origin/alpha |
      |        | git merge --no-edit main         |
      |        | git push                         |
      |        | git checkout beta                |
      | beta   | git merge --no-edit origin/beta  |
      |        | git merge --no-edit main         |
    And it prints the error:
      """
      To abort, run "git-town abort".
      To continue after having resolved conflicts, run "git-town continue".
      To continue by skipping the current branch, run "git-town skip".
      """
    And I am now on the "beta" branch
    And my uncommitted file is stashed
    And my repo now has a merge in progress

  Scenario: abort
    When I run "git-town abort"
    Then it runs the commands
      | BRANCH | COMMAND                                        |
      | beta   | git merge --abort                              |
      |        | git reset --hard {{ sha 'local beta commit' }} |
      |        | git checkout alpha                             |
      | alpha  | git checkout main                              |
      | main   | git stash pop                                  |
    And I am now on the "main" branch
    And my workspace has the uncommitted file again
    And there is no merge in progress
    And now these commits exist
      | BRANCH | LOCATION      | MESSAGE                        |
      | main   | local, origin | main commit                    |
      | alpha  | local, origin | alpha commit                   |
      |        |               | main commit                    |
      |        |               | Merge branch 'main' into alpha |
      | beta   | local         | local beta commit              |
      |        | origin        | origin beta commit             |
      | gamma  | origin        | gamma commit                   |
    And my repo still has these committed files
      | BRANCH | NAME             | CONTENT            |
      | main   | conflicting_file | main content       |
      | alpha  | conflicting_file | main content       |
      |        | feature1_file    | alpha content      |
      | beta   | conflicting_file | local beta content |

  Scenario: skip
    When I run "git-town skip"
    Then it runs the commands
      | BRANCH | COMMAND                                        |
      | beta   | git merge --abort                              |
      |        | git reset --hard {{ sha 'local beta commit' }} |
      |        | git checkout gamma                             |
      | gamma  | git merge --no-edit origin/gamma               |
      |        | git merge --no-edit main                       |
      |        | git push                                       |
      |        | git checkout main                              |
      | main   | git push --tags                                |
      |        | git stash pop                                  |
    And I am now on the "main" branch
    And my workspace has the uncommitted file again
    And there is no merge in progress
    And now these commits exist
      | BRANCH | LOCATION      | MESSAGE                        |
      | main   | local, origin | main commit                    |
      | alpha  | local, origin | alpha commit                   |
      |        |               | main commit                    |
      |        |               | Merge branch 'main' into alpha |
      | beta   | local         | local beta commit              |
      |        | origin        | origin beta commit             |
      | gamma  | local, origin | gamma commit                   |
      |        |               | main commit                    |
      |        |               | Merge branch 'main' into gamma |
    And my repo now has these committed files
      | BRANCH | NAME             | CONTENT            |
      | main   | conflicting_file | main content       |
      | alpha  | conflicting_file | main content       |
      |        | feature1_file    | alpha content      |
      | beta   | conflicting_file | local beta content |
      | gamma  | conflicting_file | main content       |
      |        | feature3_file    | gamma content      |

  Scenario: continue with unresolved conflict
    When I run "git-town continue"
    Then it runs no commands
    And it prints the error:
      """
      you must resolve the conflicts before continuing
      """
    And I am still on the "beta" branch
    And my uncommitted file is stashed
    And my repo still has a merge in progress

  Scenario: resolve and continue
    When I resolve the conflict in "conflicting_file"
    And I run "git-town continue"
    Then it runs the commands
      | BRANCH | COMMAND                          |
      | beta   | git commit --no-edit             |
      |        | git push                         |
      |        | git checkout gamma               |
      | gamma  | git merge --no-edit origin/gamma |
      |        | git merge --no-edit main         |
      |        | git push                         |
      |        | git checkout main                |
      | main   | git push --tags                  |
      |        | git stash pop                    |
    And I am now on the "main" branch
    And my workspace has the uncommitted file again
    And all branches are now synchronized
    And there is no merge in progress
    And my repo now has these committed files
      | BRANCH | NAME                 | CONTENT             |
      | main   | conflicting_file     | main content        |
      | alpha  | conflicting_file     | main content        |
      |        | feature1_file        | alpha content       |
      | beta   | conflicting_file     | resolved content    |
      |        | feature2_origin_file | origin beta content |
      | gamma  | conflicting_file     | main content        |
      |        | feature3_file        | gamma content       |

  Scenario: resolve, commit, and continue
    When I resolve the conflict in "conflicting_file"
    And I run "git commit --no-edit"
    And I run "git-town continue"
    Then it runs the commands
      | BRANCH | COMMAND                          |
      | beta   | git push                         |
      |        | git checkout gamma               |
      | gamma  | git merge --no-edit origin/gamma |
      |        | git merge --no-edit main         |
      |        | git push                         |
      |        | git checkout main                |
      | main   | git push --tags                  |
      |        | git stash pop                    |
