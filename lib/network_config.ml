(*
 * Copyright (C) Citrix Systems Inc.
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU Lesser General Public License as published
 * by the Free Software Foundation; version 2.1 only. with the special
 * exception on linking described in file LICENSE.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Lesser General Public License for more details.
 *)

open Network_interface

open Fun
open Xstringext

module D = Debug.Make(struct let name = "network_config" end)
open D

exception Read_error
exception Write_error

let config_file_path = "/var/lib/xcp/networkd.db"

let write_config config =
	try
		let config_json = config |> rpc_of_config_t |> Jsonrpc.to_string in
		Unixext.write_string_to_file config_file_path config_json
	with e ->
		error "Error while trying to write networkd configuration: %s\n%s"
			(Printexc.to_string e) (Printexc.get_backtrace ());
		raise Write_error

let read_config () =
	try
		let config_json = Unixext.string_of_file config_file_path in
		config_json |> Jsonrpc.of_string |> config_t_of_rpc
	with e ->
		error "Error while trying to read networkd configuration: %s\n%s"
			(Printexc.to_string e) (Printexc.get_backtrace ());
		raise Read_error

