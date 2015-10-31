
-module(mod_last_seen).

-author('satishck1992@gmail.com').

-behaviour(gen_mod).

-define(EJABBERD_DEBUG, true).

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
			store_info(Packet, From);
		S when (S==get) ->
			send_last_seen_info(Packet ,From);
		_ ->
			ok
	end,
	Packet.

packet_type(Packet) -> 
	case {xml:get_tag_attr_s(<<"method">>, Packet),
		xml:get_tag_attr_s(<<"type">>, Packet)} of
	{<<"last_seen">>, <<"get">>} ->
		get;
	{<<"last_seen">>, <<"set">>} ->
		set;
	_ ->
		false
	end.


send_last_seen_info(Packet, From) ->
	{Value, User} =  xml:get_tag_attr(<<"queried">>, Packet),
	LServer = From#jid.lserver,
    case ejabberd_odbc:sql_query(
           LServer,
           [<<"select last_seen from users " >>, 
           		<<" where username  = ">>,
           		<<"'">>, User, <<"';">>]) of

        {selected, _, [Timestamp]} -> 
        	xml:get_tag_attr_s("<<asdfdas>>", Timestamp),
        	send_ack_response(From, Timestamp, Packet)
    end.	

send_ack_response(From, Timestamp, Packet) ->
    RegisterFromJid = <<"dev@mm.io">>, %used in ack stanza
    ReceiptId = xml:get_tag_attr_s(<<"id">>, Packet),
    XmlBody = #xmlel{name = <<"iq">>,
              		    attrs = [{<<"from">>, RegisterFromJid}, {<<"to">>, jlib:jid_to_string(From)}],
              		    children =
              			[#xmlel{name = <<"last_seen">>,
              				attrs = [{<<"timestamp">>, Timestamp}, {<<"id">>, ReceiptId} ],
              				children = []}]},
    ejabberd_router:route(jlib:string_to_jid(RegisterFromJid), From, XmlBody).

store_info(Packet, From) ->
    Username = From#jid.luser,
    LServer = From#jid.lserver,
    Timestamp = xml:get_tag_attr_s(<<"timestamp">>, Packet),
    ejabberd_odbc:sql_query(LServer,[<<"update users set last_seen = ">>,
    								<<"'">>, Timestamp, <<"'">>,
    								<<" where username='">>,
    								Username, <<"';">>]).
