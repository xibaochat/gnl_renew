#!/usr/bin/bash

TEST_DIR=./tests/

##########
# COMMON #
##########
clean () {
	rm -rf gnl.res gnl expected.res ouput_f1 output_f0
}

print_test_type () {
	echo -e "\e[94m==== \e[45m$1\e[49m \e[49m====\e[39m"
}

compile_test_bonus () {
	# $1 ~> name of test c source file
	# $2 ~> buffer size
	echo -e "\e[4m\e[93mBUFFER_SIZE = $2\e[39m\e[0m"
	gcc -Wall -Wextra -Werror get_next_line.c get_next_line_utils.c $TEST_DIR/src/$1 -I . -D BUFFER_SIZE=$2 -o gnl
}

compile_test_bonus () {
	# $1 ~> name of test c source file
	# $2 ~> buffer size
	echo -e "\e[4m\e[93mBUFFER_SIZE = $2\e[39m\e[0m"
	gcc -Wall -Wextra -Werror get_next_line_bonus.c get_next_line_utils_bonus.c $TEST_DIR/src/$1 -I . -D BUFFER_SIZE=$2 -o gnl
}

#########
# BASIC #
#########
basic_tester () {
	printf "$1: "
	./gnl $TEST_DIR/files/$1 2>&- > gnl.res
	diff $TEST_DIR/files/$1 gnl.res 2>/dev/null > /dev/null
	if [[ $? -eq 0 ]];
	then
		echo -e "\e[32mOK\e[39m"
	else
		echo  -e "\e[31mFAIL\e[39m"
		clean
		exit
	fi
}

basic_test () {
	basic_tester one_line
	basic_tester medium_file
	basic_tester medium_plus_file
	basic_tester one_new_line
	basic_tester lot_of_new_line
	basic_tester one_char_per_line
	basic_tester one_char
	basic_tester one_huge_line
}

print_test_type "BASICS"

# 32
compile_test_bonus basic_tests.c 32
basic_test
# 42
compile_test_bonus basic_tests.c 42
basic_test
# 1
compile_test_bonus basic_tests.c 1
basic_test
# 10000
compile_test_bonus basic_tests.c 10000
basic_test
# 9999999
compile_test_bonus basic_tests.c 9999999
basic_test

#############
# FEW LINES #
#############

few_lines_tester () {
	printf "$1: "
	./gnl $TEST_DIR/files/$1 2>&- > gnl.res
	head -n 3 $TEST_DIR/files/$1 > expected.res
	diff gnl.res expected.res 2>/dev/null > /dev/null
	if [[ $? -eq 0 ]];
	then
		echo -e "\e[32mOK\e[39m"
	else
		echo  -e "\e[31mFAIL\e[39m"
		clean
		exit
	fi
}

few_lines_test () {
	few_lines_tester medium_file
	few_lines_tester medium_plus_file
	few_lines_tester lot_of_new_line
	few_lines_tester one_char_per_line
}

print_test_type "Few Lines"
# 32
compile_test_bonus few_lines.c 32
few_lines_test
# 42
compile_test_bonus few_lines.c 42
few_lines_test
# 1
compile_test_bonus few_lines.c 1
few_lines_test
# 10000
compile_test_bonus few_lines.c 10000
few_lines_test
# 9999999
compile_test_bonus few_lines.c 9999999
few_lines_test

################
# RETURN VALUE #
################
return_value_tester () {
	printf "$1: "
	./gnl $TEST_DIR/files/$1
	if [ $? -eq $2 ];
	then
		echo -e "\e[32mOK\e[39m"
	else
		echo  -e "\e[31mFAIL\e[39m"
		clean
		exit
	fi
}

print_test_type "Return values"
# 32
compile_test_bonus return_value.c 32
return_value_tester empty_file 0

# 42
compile_test_bonus return_value.c 42
return_value_tester empty_file 0

# 1
compile_test_bonus return_value.c 1
return_value_tester empty_file 0

# 1000
compile_test_bonus return_value.c 1000
return_value_tester empty_file 0

# 9999999
compile_test_bonus return_value.c 9999999
return_value_tester empty_file 0

#########
# STDIN #
#########
stdin_tester () {
	printf "$1: "
	echo $2 > expected.res
	echo $2 | ./gnl 2>&- > gnl.res
	diff expected.res gnl.res
	if [[ $? -eq 0 ]];
	then
		echo -e "\e[32mOK\e[39m"
	else
		echo  -e "\e[31mFAIL\e[39m"
		clean
		exit
	fi
}




stdin_test () {
	stdin_tester "test00" "XibaoHatesMeishanu"
	stdin_tester "test01" "A\nB\nC"
	stdin_tester "test02" ""
	stdin_tester "test03" "\n\n\n\n\n"
	stdin_tester "test04" "\n"
	stdin_tester "test05" `cat $TEST_DIR/files/medium_file`
	stdin_tester "test06" `cat $TEST_DIR/files/empty_file`
	stdin_tester "test07" `cat $TEST_DIR/files/small_test`
	stdin_tester "test08" `cat $TEST_DIR/files/one_huge_line`
	stdin_tester "test09" `cat $TEST_DIR/files/one_char`
}

print_test_type "Stdin"

# 32
compile_test_bonus stdin.c 32
stdin_test

# 42
compile_test_bonus stdin.c 42
stdin_test

# 1
compile_test_bonus stdin.c 1
stdin_test

# 1000
compile_test_bonus stdin.c 1000
stdin_test

# 9999999
compile_test_bonus stdin.c 999999
stdin_test


############
# MULTI_FD #
############
multi_fd_test()
{
	printf "$1 - $2: "
	./gnl $TEST_DIR/files/$1 $TEST_DIR/files/$2 2>&-
	diff output_f0 $TEST_DIR/files/$1 2>/dev/null > /dev/null
	if [[ $? -eq 0 ]];
	then
		printf "\e[32mOK \e[39m"
	else
		printf "\e[31mFAIL\e[39m"
		clean
		exit
	fi

	diff output_f1 $TEST_DIR/files/$2 2>/dev/null > /dev/null
	if [[ $? -eq 0 ]];
	then
		echo -e "\e[32mOK\e[39m"
	else
		echo  -e "\e[31mFAIL\e[39m"
		clean
		exit
	fi

	rm -f output_f0 output_f1
}

multi_fd_tester()
{
	multi_fd_test medium_plus_file medium_file
	multi_fd_test empty_file lot_of_new_line
	multi_fd_test lot_of_new_line medium_file
	multi_fd_test medium_file medium_plus_file
	multi_fd_test medium_plus_file one
	multi_fd_test one_char one_char_per_line
	multi_fd_test one_huge_line one_line
	multi_fd_test one_line one_new_line
	multi_fd_test one_new_line small_test
	multi_fd_test empty_file empty_file
}

print_test_type "Multi_FD"
# 32
compile_test_bonus multi_fd.c 32
multi_fd_tester

# 42
compile_test_bonus multi_fd.c 42
multi_fd_tester

#1
compile_test_bonus multi_fd.c 1
multi_fd_tester

#999999
compile_test_bonus multi_fd.c 999999
multi_fd_tester

#1000
compile_test_bonus multi_fd.c 1000
multi_fd_tester

echo -e "\e[32m\n\n\tNice work cute cat!\e[39m\n\n"

# CLEAN
clean