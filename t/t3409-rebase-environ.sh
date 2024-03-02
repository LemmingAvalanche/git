#!/bin/sh

test_description='git rebase interactive environment'

TEST_PASSES_SANITIZE_LEAK=true
. ./test-lib.sh

test_expect_success 'setup' '
	test_commit one &&
	test_commit two &&
	test_commit three
'

test_expect_success 'rebase --exec does not muck with GIT_DIR' '
	git rebase --exec "printf %s \$GIT_DIR >environ" HEAD~1 &&
	test_must_be_empty environ
'

test_expect_success 'rebase --exec does not muck with GIT_WORK_TREE' '
	git rebase --exec "printf %s \$GIT_WORK_TREE >environ" HEAD~1 &&
	test_must_be_empty environ
'

test_expect_success 'rebase --exec cmd can access GIT_REBASE_BRANCH' '
	write_script cmd <<-\EOF &&
printf "%s\n" $GIT_REBASE_BRANCH
EOF
	git rebase --exec ./cmd >actual HEAD~1 &&
cat <<\EOF >expect &&
master
EOF
	test_cmp expect actual
'

test_expect_success 'rebase --exec cmd has no GIT_REBASE_BRANCH when on detached HEAD' '
	test_when_finished git checkout master &&
	git checkout --detach &&
	write_script cmd <<-\EOF &&
printf "%s" $GIT_REBASE_BRANCH
EOF
	git rebase --exec ./cmd >environ HEAD~1 &&
	test_must_be_empty environ
'

test_done
