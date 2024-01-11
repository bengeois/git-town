package dialog

import (
	"fmt"

	"github.com/git-town/git-town/v11/src/git/gitdomain"
	"github.com/git-town/git-town/v11/src/messages"
)

// SelectSquashCommitAuthor allows the user to select an author amongst a given list of authors.
func SelectSquashCommitAuthor(branch gitdomain.LocalBranchName, authors []string) (string, bool, error) {
	if len(authors) == 1 {
		return authors[0], false, nil
	}
	return radioList(radioListArgs{
		entries:      authors,
		defaultEntry: "",
		help:         fmt.Sprintf(messages.BranchAuthorMultiple, branch),
	})
}
