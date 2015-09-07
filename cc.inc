{ Delphi 5 }
{$IFDEF	VER130}
  {$DEFINE DELPHI5}
  {$DEFINE SupportedCompiler}
{$ENDIF}

{ Delphi 6 }
{$IFDEF	VER140}
  {$DEFINE DELPHI6ANDUP}
  {$DEFINE SupportedCompiler}
{$ENDIF}

{ Delphi 7 }
{$IFDEF	VER150}
  {$DEFINE DELPHI6ANDUP}
  {$DEFINE SupportedCompiler}
{$ENDIF}

{ Delphi 2005 }
{$IFDEF	VER170}
  {$DEFINE DELPHI6ANDUP}
  {$DEFINE VERSION2005orHigher}
  {$DEFINE SupportedCompiler}
{$ENDIF}

{ Delphi 2006 & 2007}
{$IFDEF	VER180}
  {$DEFINE DELPHI6ANDUP}
  {$DEFINE VERSION2005orHigher}
  {$DEFINE SupportedCompiler}
{$ENDIF}

{ Delphi 2009 }
{$IFDEF VER200}
  {$DEFINE DELPHI6ANDUP}
  {$DEFINE VERSION2005orHigher}
  {$DEFINE SupportedCompiler}
{$ENDIF}

{ Delphi 2010 }
{$IFDEF VER210}
  {$DEFINE DELPHI6ANDUP}
  {$DEFINE VERSION2005orHigher}
  {$DEFINE SupportedCompiler}
{$ENDIF}

{ Delphi XE }
{$IFDEF VER220}
  {$DEFINE DELPHI6ANDUP}
  {$DEFINE VERSION2005orHigher}
  {$DEFINE SupportedCompiler}
{$ENDIF}

{ Delphi XE2 }
{$IFDEF VER230}
  {$DEFINE DELPHI6ANDUP}
  {$DEFINE VERSION2005orHigher}
  {$DEFINE XE2orHigher}
  {$DEFINE SupportedCompiler}
{$ENDIF}

{ Delphi XE3 }
{$IFDEF VER240}
  {$DEFINE DELPHI6ANDUP}
  {$DEFINE VERSION2005orHigher}
  {$DEFINE XE2orHigher}
  {$DEFINE SupportedCompiler}
{$ENDIF}

{ Delphi XE4 }
{$IFDEF VER250}
  {$DEFINE DELPHI6ANDUP}
  {$DEFINE VERSION2005orHigher}
  {$DEFINE XE2orHigher}
  {$DEFINE SupportedCompiler}
{$ENDIF}

{ Delphi XE5 }
{$IFDEF VER260}
  {$DEFINE DELPHI6ANDUP}
  {$DEFINE VERSION2005orHigher}
  {$DEFINE XE2orHigher}
  {$DEFINE SupportedCompiler}
{$ENDIF}

{ Delphi XE6 }
{$IFDEF VER270}
  {$DEFINE DELPHI6ANDUP}
  {$DEFINE VERSION2005orHigher}
  {$DEFINE XE2orHigher}
  {$DEFINE SupportedCompiler}
{$ENDIF}

{ Delphi XE7 }
{$IFDEF VER280}
  {$DEFINE DELPHI6ANDUP}
  {$DEFINE VERSION2005orHigher}
  {$DEFINE XE2orHigher}
  {$DEFINE SupportedCompiler}
{$ENDIF}

{ Delphi XE8 }
{$IFDEF VER290}
  {$DEFINE DELPHI6ANDUP}
  {$DEFINE VERSION2005orHigher}
  {$DEFINE XE2orHigher}
  {$DEFINE SupportedCompiler}
{$ENDIF}

{ Delphi 10 Seattle }
{$IFDEF VER300}
  {$DEFINE DELPHI6ANDUP}
  {$DEFINE VERSION2005orHigher}
  {$DEFINE XE2orHigher}
  {$DEFINE SupportedCompiler}
{$ENDIF}


{$IFNDEF SupportedCompiler}
  {$MESSAGE FATAL 'Non-supported compiler.'}
{$ENDIF}

