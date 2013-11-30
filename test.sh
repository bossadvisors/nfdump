#!/bin/sh
#  This file is part of the nfdump project.
#
#  Copyright (c) 2004, SWITCH - Teleinformatikdienste fuer Lehre und Forschung
#  All rights reserved.
#  
#  Redistribution and use in source and binary forms, with or without 
#  modification, are permitted provided that the following conditions are met:
#  
#   * Redistributions of source code must retain the above copyright notice, 
#     this list of conditions and the following disclaimer.
#   * Redistributions in binary form must reproduce the above copyright notice, 
#     this list of conditions and the following disclaimer in the documentation 
#     and/or other materials provided with the distribution.
#   * Neither the name of SWITCH nor the names of its contributors may be 
#     used to endorse or promote products derived from this software without 
#     specific prior written permission.
#  
#  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" 
#  AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE 
#  IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE 
#  ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE 
#  LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR 
#  CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF 
#  SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS 
#  INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN 
#  CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) 
#  ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE 
#  POSSIBILITY OF SUCH DAMAGE.
#  
#  $Author: peter $
#
#  $Id: test.sh 62 2006-03-08 12:59:51Z peter $
#
#  $LastChangedRevision: 62 $
#  
# 

set -e

# run filter and type tests
./nftest

# Check for correct output
./nfgen | ./nfdump -q -o extended  > test1.out
diff test1.out nfdump.test.out

./nfgen | ./nfdump -q -w  test.flows
./nfdump -q -r test.flows -o extended > test2.out
diff test2.out nfdump.test.out

rm -r test1.out test2.out

# create tmp dir for flow replay
if [ -d tmp ]; then
	rm -f tmp/*
	rmdir tmp
fi
mkdir tmp

# Start nfcapd on localhost and replay flows
echo
echo -n Starting nfcapd ...
./nfcapd -p 65530 -l tmp -D -P tmp/pidfile
sleep 1
echo done.
echo -n Replay flows ...
./nfreplay -r test.flows -v9 -H 127.0.0.1 -p 65530
echo done.
sleep 1 

echo -n Terminate nfcapd ...
kill -TERM `cat tmp/pidfile`;
sleep 1
echo done.

if [ -f tmp/pidfile ]; then
	echo nfcapd does not terminate
	exit
fi

diff test.flows tmp/nfcapd.*

rm test.flows tmp/nfcapd.*
rmdir tmp

echo All tests successful.
