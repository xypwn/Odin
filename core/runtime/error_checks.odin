package runtime

bounds_trap :: proc "contextless" () -> ! {
	when ODIN_OS == "windows" {
		windows_trap_array_bounds();
	} else {
		trap();
	}
}

type_assertion_trap :: proc "contextless" () -> ! {
	when ODIN_OS == "windows" {
		windows_trap_type_assertion();
	} else {
		trap();
	}
}


bounds_check_error :: proc "contextless" (file: string, line, column: int, index, count: int) {
	if 0 <= index && index < count {
		return;
	}
	handle_error :: proc "contextless" (file: string, line, column: int, index, count: int) {
		context = default_context();
		print_caller_location(Source_Code_Location{file, line, column, "", 0});
		print_string(" Index ");
		print_i64(i64(index));
		print_string(" is out of bounds range 0:");
		print_i64(i64(count));
		print_byte('\n');
		bounds_trap();
	}
	handle_error(file, line, column, index, count);
}

slice_handle_error :: proc "contextless" (file: string, line, column: int, lo, hi: int, len: int) -> ! {
	context = default_context();
	print_caller_location(Source_Code_Location{file, line, column, "", 0});
	print_string(" Invalid slice indices: ");
	print_i64(i64(lo));
	print_string(":");
	print_i64(i64(hi));
	print_string(":");
	print_i64(i64(len));
	print_byte('\n');
	bounds_trap();
}

slice_expr_error_hi :: proc "contextless" (file: string, line, column: int, hi: int, len: int) {
	if 0 <= hi && hi <= len {
		return;
	}
	slice_handle_error(file, line, column, 0, hi, len);
}

slice_expr_error_lo_hi :: proc "contextless" (file: string, line, column: int, lo, hi: int, len: int) {
	if 0 <= lo && lo <= len && lo <= hi && hi <= len {
		return;
	}
	slice_handle_error(file, line, column, lo, hi, len);
}

dynamic_array_expr_error :: proc "contextless" (file: string, line, column: int, low, high, max: int) {
	if 0 <= low && low <= high && high <= max {
		return;
	}
	handle_error :: proc "contextless" (file: string, line, column: int, low, high, max: int) {
		context = default_context();
		print_caller_location(Source_Code_Location{file, line, column, "", 0});
		print_string(" Invalid dynamic array values: ");
		print_i64(i64(low));
		print_string(":");
		print_i64(i64(high));
		print_string(":");
		print_i64(i64(max));
		print_byte('\n');
		bounds_trap();
	}
	handle_error(file, line, column, low, high, max);
}


type_assertion_check :: proc "contextless" (ok: bool, file: string, line, column: int, from, to: typeid) {
	if ok {
		return;
	}
	handle_error :: proc "contextless" (file: string, line, column: int, from, to: typeid) {
		context = default_context();
		print_caller_location(Source_Code_Location{file, line, column, "", 0});
		print_string(" Invalid type assertion from ");
		print_typeid(from);
		print_string(" to ");
		print_typeid(to);
		print_byte('\n');
		type_assertion_trap();
	}
	handle_error(file, line, column, from, to);
}

make_slice_error_loc :: inline proc "contextless" (loc := #caller_location, len: int) {
	if 0 <= len {
		return;
	}
	handle_error :: proc "contextless" (loc: Source_Code_Location, len: int) {
		context = default_context();
		print_caller_location(loc);
		print_string(" Invalid slice length for make: ");
		print_i64(i64(len));
		print_byte('\n');
		bounds_trap();
	}
	handle_error(loc, len);
}

make_dynamic_array_error_loc :: inline proc "contextless" (using loc := #caller_location, len, cap: int) {
	if 0 <= len && len <= cap {
		return;
	}
	handle_error :: proc "contextless" (loc: Source_Code_Location, len, cap: int) {
		context = default_context();
		print_caller_location(loc);
		print_string(" Invalid dynamic array parameters for make: ");
		print_i64(i64(len));
		print_byte(':');
		print_i64(i64(cap));
		print_byte('\n');
		bounds_trap();
	}
	handle_error(loc, len, cap);
}

make_map_expr_error_loc :: inline proc "contextless" (loc := #caller_location, cap: int) {
	if 0 <= cap {
		return;
	}
	handle_error :: proc "contextless" (loc: Source_Code_Location, cap: int) {
		context = default_context();
		print_caller_location(loc);
		print_string(" Invalid map capacity for make: ");
		print_i64(i64(cap));
		print_byte('\n');
		bounds_trap();
	}
	handle_error(loc, cap);
}





bounds_check_error_loc :: inline proc "contextless" (using loc := #caller_location, index, count: int) {
	bounds_check_error(file_path, int(line), int(column), index, count);
}

slice_expr_error_hi_loc :: inline proc "contextless" (using loc := #caller_location, hi: int, len: int) {
	slice_expr_error_hi(file_path, int(line), int(column), hi, len);
}

slice_expr_error_lo_hi_loc :: inline proc "contextless" (using loc := #caller_location, lo, hi: int, len: int) {
	slice_expr_error_lo_hi(file_path, int(line), int(column), lo, hi, len);
}

dynamic_array_expr_error_loc :: inline proc "contextless" (using loc := #caller_location, low, high, max: int) {
	dynamic_array_expr_error(file_path, int(line), int(column), low, high, max);
}