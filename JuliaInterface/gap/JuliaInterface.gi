#
# JuliaInterface: Test interface to julia
#
# Implementations
#

#! @Arguments function_name[,module_name]
#! @Returns a Julia function
#! @Desctiption
#!  Returns the GAP object corresponding to the Julia function
#!  with name <A>function_name</A> in module <A>module_name</A>.
#!  The default module is Main.
InstallGlobalFunction( JuliaFunction,
  function( arglist... )
    if Length( arglist ) = 1 and IsString( arglist[ 1 ] ) then
        return __JuliaFunction( arglist[ 1 ] );
    elif Length( arglist ) = 2 and ForAll( arglist, IsString ) then
        return CallFuncList( __JuliaFunctionByModule, arglist );
    fi;
    Error( "arguments must be strings function_name[,module_name]" );
end );

InstallMethod( JuliaUnbox,
               [ IsJuliaObject ],
    __JuliaUnbox );

InstallMethod( JuliaBox,
                [ IsObject ],
  function( obj )
    local result;
    
    result := __JuliaBox( obj );
    if result = fail then
        TryNextMethod();
    fi;
    return result;
end );

InstallMethod( CallFuncList,
               [ IsJuliaFunction, IsList ],

  function( julia_func, argument_list )

    if Length( argument_list ) = 0 then

        return __JuliaCallFunc0Arg( julia_func );

    elif Length( argument_list ) = 1 then

        return __JuliaCallFunc1Arg( julia_func, JuliaBox( argument_list[ 1 ] ) );

    elif Length( argument_list ) = 2 then

        return __JuliaCallFunc2Arg( julia_func, JuliaBox( argument_list[ 1 ] ), JuliaBox( argument_list[ 2 ] ) );

    elif Length( argument_list ) = 3 then

        return __JuliaCallFunc3Arg( julia_func, JuliaBox( argument_list[ 1 ] ), JuliaBox( argument_list[ 2 ] ), JuliaBox( argument_list[ 3 ] ) );

    fi;

    return __JuliaCallFuncXArg( julia_func, List( argument_list, JuliaBox ) );

end );

BindJuliaFunc( "string" );

BindJuliaFunc( "include" );

BindGlobal( "JuliaKnownFiles", [] );

BindGlobal( "JuliaIncludeFile", function( filename )
    if not filename in JuliaKnownFiles then
      __JuliaFunctions.include( filename );
      AddSet( JuliaKnownFiles, filename );
    fi;
end );

InstallMethod( ViewString,
               [ IsJuliaObject ],

  function( julia_obj )

    return Concatenation( "<Julia: ", String( julia_obj ), ">" );

end );

InstallMethod( String,
               [ IsJuliaObject ],

  function( julia_obj )

    return JuliaUnbox( __JuliaFunctions.string( julia_obj ) );

end );

InstallMethod( CallFuncList,
               [ IsJuliaFunction, IsList ],

  function( julia_func, argument_list )

    if Length( argument_list ) = 0 then

        return __JuliaCallFunc0Arg( julia_func );

    elif Length( argument_list ) = 1 then

        return __JuliaCallFunc1Arg( julia_func, JuliaBox( argument_list[ 1 ] ) );

    elif Length( argument_list ) = 2 then

        return __JuliaCallFunc2Arg( julia_func, JuliaBox( argument_list[ 1 ] ), JuliaBox( argument_list[ 2 ] ) );

    elif Length( argument_list ) = 3 then

        return __JuliaCallFunc3Arg( julia_func, JuliaBox( argument_list[ 1 ] ), JuliaBox( argument_list[ 2 ] ), JuliaBox( argument_list[ 3 ] ) );

    fi;

    return __JuliaCallFuncXArg( julia_func, List( argument_list, JuliaBox ) );

end );

InstallGlobalFunction( ImportJuliaModuleIntoGAP,
  function( name )
    local julia_list_func, function_list, variable_list, i, current_module_rec;

    JuliaEvalString( Concatenation( "using ", name ) );
    Julia.(name) := rec();
    current_module_rec := Julia.(name);
    julia_list_func := JuliaFunction( "get_function_symbols_in_module", "GAPUtils" );
    function_list := JuliaStructuralUnbox( julia_list_func( JuliaModule( name ) ) );
    for i in function_list do
        current_module_rec.(i) := JuliaFunction( i, name );
    od;
    julia_list_func := JuliaFunction( "get_variable_symbols_in_module", "GAPUtils" );
    variable_list := JuliaStructuralUnbox( julia_list_func( JuliaModule( name ) ) );
    for i in variable_list do
        current_module_rec.(i) := JuliaGetGlobalVariableByModule( i, name );
    od;
end );

InstallGlobalFunction( JuliaStructuralUnbox,
  function( object ) 
    local unboxed_obj;
    unboxed_obj := JuliaUnbox( object );
    if IsList( unboxed_obj ) and not IsString( unboxed_obj ) then
        return List( unboxed_obj, JuliaStructuralUnbox );
    fi;
    return unboxed_obj;
end );

