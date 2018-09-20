##############################################################################
##
##  realcyc.g
##
##  The Julia utilities are implemented in 'julia/realcyc.jl'.
##


##############################################################################
##
##  Notify the Julia part.
##
JuliaIncludeFile(
    Filename( DirectoriesPackageLibrary( "JuliaExperimental", "julia" ),
    "realcyc.jl" ) );

ImportJuliaModuleIntoGAP( "GAPRealCycModule" );


BindGlobal( "IsPositiveRealPartCyclotomic", function( cyc )
    local coeffs, denom, res;

    if not IsCyc( cyc ) then
      Error( "<cyc> must be a cyclotomic number" );
    elif cyc = 0 then
      # Arb would not return 'true' for a positivity or negativity test.
      return false;
    elif IsRat( cyc ) then
      # GAP can answer the question.
      return IsPosRat( cyc );
    fi;

    coeffs:= COEFFS_CYC( cyc );
    denom:= DenominatorCyc( cyc );
    if denom <> 1 then
      coeffs:= coeffs * denom;
    fi;

    if ForAll( coeffs, IsSmallIntRep ) then
      coeffs:= ConvertedToJulia( coeffs );
    else
      coeffs:= JuliaArrayOfFmpz( coeffs );
    fi;
    
    res:= Julia.GAPRealCycModule.isPositiveRealPartCyc( coeffs );
    if ValueOption( "ShowPrecision" ) = true then
      Print( "#I  precision needed: ", ConvertedFromJulia( res[2] ), "\n" );
    fi;
    return ConvertedFromJulia( res[1] );
end );


##############################################################################
##
#E
