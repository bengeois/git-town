package dialog

import (
	"fmt"

	"github.com/git-town/git-town/v16/internal/cli/dialog/components"
	"github.com/git-town/git-town/v16/internal/config/configdomain"
	"github.com/git-town/git-town/v16/internal/messages"
	. "github.com/git-town/git-town/v16/pkg/prelude"
)

const (
	featureRegexTitle = `Regular expression for feature branches`
	FeatureRegexHelp  = `
Branches matching this regular expression are treated as feature branches.
This setting is effective only when used together with the "default-branch-type" setting.

`
)

func FeatureRegex(existingValue Option[configdomain.FeatureRegex], inputs components.TestInput) (Option[configdomain.FeatureRegex], bool, error) {
	value, aborted, err := components.TextField(components.TextFieldArgs{
		ExistingValue: existingValue.String(),
		Help:          FeatureRegexHelp,
		Prompt:        "Feature regex: ",
		TestInput:     inputs,
		Title:         featureRegexTitle,
	})
	if err != nil {
		return None[configdomain.FeatureRegex](), false, err
	}
	fmt.Printf(messages.FeatureRegex, components.FormattedSelection(value, aborted))
	featureRegex, err := configdomain.ParseFeatureRegex(value)
	return featureRegex, aborted, err
}