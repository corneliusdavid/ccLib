unit uSearchRecList;

interface

uses
  System.SysUtils, System.IOUtils;

type
  {$REGION 'XMLDoc'}
  /// <summary>
  ///   a call procedure type used in GetSearchRecs for when a path is
  ///   traversed
  /// </summary>
  /// <remarks>
  ///   passes the current Path to the calling method which can change the
  ///   value of the Stop parameter to halt the search process
  /// </remarks>
  /// <example>
  ///   <para>
  ///     an example anonymous method of this type could be used to update a
  ///     status bar:
  ///   </para>
  ///   <para>
  ///     procedure (const Path: string; var Stop: Boolean) <br />begin <br />
  ///     StatusBar1.Panels[0].Text := Path; <br />StatusBar1.Update; <br />
  ///     Application.ProcessMessages; <br />Stop := DoStop; // could a
  ///     private var set by a button <br />end
  ///   </para>
  /// </example>
  {$ENDREGION}
  TPathStatusProc = reference to procedure (const Path: string; var Stop: Boolean);
  {$REGION 'XMLDoc'}
  /// <summary>
  ///   when a match file is found, the TSearchRec is passed to this procedure
  /// </summary>
  /// <remarks>
  ///   the only way to get the SearchRec found is to define a procedure that
  ///   handles the FileInfo parameter given to it
  /// </remarks>
  /// <example>
  ///   <para>
  ///     define an anonymous procedure such as this:
  ///   </para>
  ///   <para>
  ///     procedure (FileInfo: TSearchRec) <br />begin <br />
  ///     MySearchList.Add(FileInfo); <br />end
  ///   </para>
  /// </example>
  {$ENDREGION}
  TFileFoundProc = reference to procedure (FileInfo: TSearchRec);

{$REGION 'XMLDoc'}
/// <summary>
///   Walk through a directory tree looking for specific files and return them
///   in a callback procedure
/// </summary>
/// <param name="Path">
///   The path to search for files
/// </param>
/// <param name="Pattern">
///   A file pattern to look for
/// </param>
/// <param name="Recursive">
///   True or False - whether to traverse subfolders or not
/// </param>
/// <param name="PathStatusProc">
///   A procedure of type TPathStatusProc for the calling method to define to
///   get notified every time a sub-folder is recursed into
/// </param>
/// <param name="FileFoundProc">
///   A procedure of type TFileFoundProc called for each found file, giving the
///   TSearchRec to the calling method.
/// </param>
{$ENDREGION}
procedure GetSearchRecs(const Path, Pattern: string; const Recursive: Boolean; PathStatusProc: TPathStatusProc; FileFoundProc: TFileFoundProc);


implementation

procedure GetSearchRecs(const Path, Pattern: string; const Recursive: Boolean; PathStatusProc: TPathStatusProc; FileFoundProc: TFileFoundProc);
{ adapted from TDirectory.WalkThroughDirectory in System.IOUtils }
const
  FCCurrentDir: string = '.';
  FCParentDir: string = '..';
var
  SearchRec: TSearchRec;
  Stop: Boolean;
begin
  if FindFirst(TPath.Combine(Path, '*'), faAnyFile, SearchRec) = 0 then
    try
      repeat
        if SearchRec.Attr and System.SysUtils.faDirectory <> 0 then begin
          // if a directory, optionally recurse into it
          if Recursive and (SearchRec.Name <> FCCurrentDir) and (SearchRec.Name <> FCParentDir) then begin
            GetSearchRecs(TPath.Combine(Path, SearchRec.Name), Pattern, Recursive, PathStatusProc, FileFoundProc);
            // notify the calling method about the change in path
            if Assigned(PathStatusProc) then
              PathStatusProc(Path, Stop);
            // optionally halt the searching
            if Stop then
              Break;
          end;
        end else if TPath.MatchesPattern(SearchRec.Name, Pattern, False) then
          // found a file matching our pattern, let the calling method have it
          if Assigned(FileFoundProc) then
            FileFoundProc(SearchRec);
      until FindNext(SearchRec) <> 0;
    finally
      FindClose(SearchRec);
    end;
end;

end.
