#! /bin/bash -e

die() {
    echo "$@" 1>&2
    exit 2
}

do_hdr() {
    cat <<EOF
/******************************************************************************/
/*          postlicyd: a postfix policy daemon with a lot of features         */
/*          ~~~~~~~~~                                                         */
/*  ________________________________________________________________________  */
/*                                                                            */
/*  Redistribution and use in source and binary forms, with or without        */
/*  modification, are permitted provided that the following conditions        */
/*  are met:                                                                  */
/*                                                                            */
/*  1. Redistributions of source code must retain the above copyright         */
/*     notice, this list of conditions and the following disclaimer.          */
/*  2. Redistributions in binary form must reproduce the above copyright      */
/*     notice, this list of conditions and the following disclaimer in the    */
/*     documentation and/or other materials provided with the distribution.   */
/*  3. The names of its contributors may not be used to endorse or promote    */
/*     products derived from this software without specific prior written     */
/*     permission.                                                            */
/*                                                                            */
/*  THIS SOFTWARE IS PROVIDED BY THE REGENTS AND CONTRIBUTORS ``AS IS'' AND   */
/*  ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE     */
/*  IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR        */
/*  PURPOSE ARE DISCLAIMED.  IN NO EVENT SHALL THE REGENTS OR CONTRIBUTORS    */
/*  BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR    */
/*  CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF      */
/*  SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS  */
/*  INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN   */
/*  CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)   */
/*  ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF    */
/*  THE POSSIBILITY OF SUCH DAMAGE.                                           */
/******************************************************************************/

/*****     THIS FILE IS AUTOGENERATED DO NOT MODIFY DIRECTLY !    *****/

EOF
}

do_h() {
    do_hdr
    cat <<EOF
#ifndef PFIXTOOLS_POLICY_TOKENS_H
#define PFIXTOOLS_POLICY_TOKENS_H

typedef enum postlicyd_token {
    PTK_UNKNOWN = -1,
`grep_self "$0" | tr 'a-z-/' 'A-Z__' | sed -e 's/.*/    PTK_&,/'`
    PTK_count,
} postlicyd_token;

extern const char *ptokens[PTK_count];

__attribute__((pure))
postlicyd_token policy_tokenize(const char *s, ssize_t len);
#endif /* PFIXTOOLS_POLICY_TOKENS_H */
EOF
}

do_tokens() {
    while read tok; do
        echo "$tok, PTK_`echo $tok | tr 'a-z-' 'A-Z_'`"
    done
}

do_c() {
    this=`basename "$0"`
    cat <<EOF | gperf -m16 -l -t -C -F",0" -Ntokenize_aux | \
        sed -e '/__gnu_inline__/d;s/\<\(__\|\)inline\>//g'
%{
`do_hdr`

#include "str.h"
#include "`echo "${this%.sh}"`.h"

static const struct tok *
tokenize_aux(const char *str, unsigned int len);

%}
struct tok { const char *name; int val; };
%%
`grep_self "$0" | do_tokens`
%%

const char *ptokens[PTK_count] = {
`grep_self "$0" | sed -e 's/.*/    "&",/'`
};

postlicyd_token policy_tokenize(const char *s, ssize_t len)
{
    if (len < 0)
        len = m_strlen(s);

    if (len) {
        const struct tok *res = tokenize_aux(s, len);
        return res ? res->val : PTK_UNKNOWN;
    } else {
        return PTK_UNKNOWN;
    }
}
EOF
}

grep_self() {
    grep '^## ' "$1" | cut -d' ' -f2
}

trap "rm -f $1" 1 2 3 15
rm -f $1
case "$1" in
    *.h) do_h > $1;;
    *.c) do_c > $1;;
    *)  die "you must ask for the 'h' or 'c' generation";;
esac
chmod -w $1

exit 0

############ Put tokens here ############
# postfix 2.1+
## request
## protocol_name
## protocol_state
## helo_name
## queue_id
## sender
## recipient
## recipient_count
## client_address
## client_name
## reverse_client_name
## instance
#
# helpers
## sender_domain
## recipient_domain
#
# postfix 2.2+
## sasl_method
## sasl_username
## sasl_sender
## size
## ccert_subject
## ccert_issuer
## ccert_fingerprint
#
# postfix 2.3+
## encryption_protocol
## encryption_cipher
## encryption_keysize
## etrn_domain
#
# postfix 2.5+
## stress
#
# request value
## smtpd_access_policy
#
# protocol_name values
## SMTP
## ESMTP
#
# protocol_state values
## CONNECT
## EHLO
## HELO
## MAIL
## RCPT
## DATA
## END-OF-MESSAGE
## VRFY
## ETRN
