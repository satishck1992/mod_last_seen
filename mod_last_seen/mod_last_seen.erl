
-module(mod_last_seen).

-author('satishck1992@gmail.com').

-behaviour(gen_mod).

-define(EJABBERD_DEBUG, true).
-define(NS_RECEIPTS, <<"urn:xmpp:receipts">>).

-include("logger.hrl").
-include("ejabberd.hrl").
-include("jlib.hrl").

-type host()    :: string().
-type name()    :: string().
-type value()   :: string().
-type opts()    :: [{name(), value()}, ...].

-export([start/2, stop/1]).
-export([on_user_send_info/4, packet_type/1, store_info/2, send_last_seen_info/2]).

-spec start(host(), opts()) -> ok.
start(Host, Opts) ->
	ejabberd_hooks:add(user_send_packet, Host, ?MODULE, on_user_send_info, 50),
	ok.

-spec stop(host()) -> ok.
stop(Host) ->
	ejabberd_hooks:delete(user_send_packet, Host, ?MODULE, on_user_send_info, 50),
	ok.

on_user_send_info(Packet, _C2SState, From, To) ->
	case packet_type(Packet) of 
		S when (S==set) ->
			store_info(Packet, From),
			ok;
		S when (S==get) ->
			send_last_seen_info(Packet ,From),
			ok;
		_ ->
			Packet
	end.

packet_type(Packet) -> 
	case {xml:get_tag_attr_s(<<"to">>, Packet)} of
	{<<"gettimedev@mm.io">>} ->
		get;
	{<<"settimedev@mm.io">>} ->
		set;
	_ ->
		false
	end.


send_last_seen_info(Packet, From) ->
    User = xml:get_subtag_cdata(Packet, <<"body">>),
	LServer = From#jid.lserver,
    case ejabberd_odbc:sql_query(
           LServer,
           [<<"select last_seen from users " >>, 
           		<<" where username  = ">>,
           		<<"'">>, User, <<"';">>]) of

        {selected, _, [[Timestamp]]} -> 
        	send_response(From, Timestamp, Packet)
    end.	

send_response(To, Timestamp, Packet) ->
    RegisterFromJid = <<"dev@mm.io">>, %used in ack stanza
	From = jlib:string_to_jid(RegisterFromJid),
    SentTo = jlib:jid_to_string(To),
    XmlBody = #xmlel{name = <<"message">>,
              		    attrs = [{<<"from">>, To}, {<<"to">>, To}],
              		    children =
              			[#xmlel{name = <<"body">>,
              				attrs = [],
              				children = [{xmlcdata, Timestamp}]}]},
    ejabberd_router:route(From, To, XmlBody).

store_info(Packet, From) ->
    Username = From#jid.luser,
    LServer = From#jid.lserver,
    Timestamp = xml:get_subtag_cdata(Packet, <<"body">>),
    ejabberd_odbc:sql_query(LServer,[<<"update users set last_seen = ">>,
    								<<"'">>, Timestamp, <<"'">>,
    								<<" where username='">>,
    								Username, <<"';">>]).
