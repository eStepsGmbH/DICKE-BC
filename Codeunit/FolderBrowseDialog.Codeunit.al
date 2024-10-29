codeunit 50073 FolderBrowseDialog
{

    trigger OnRun()
    begin
    end;

    local procedure BrowseForFolder(FolderBrowserDialog: DotNet FolderBrowserDialog; DialogResult: DotNet DialogResult)
    begin

        FolderBrowserDialog := FolderBrowserDialog.FolderBrowserDialog;
        FolderBrowserDialog.Description := 'Bitte wählen Sie einen Ordner';
        FolderBrowserDialog.SelectedPath := 'c:\dell';
        DialogResult := FolderBrowserDialog.ShowDialog;

        IF DialogResult.CompareTo(DialogResult.OK) = 0 THEN BEGIN
            IF CONFIRM(FolderBrowserDialog.SelectedPath) THEN;
        END;
    end;
}

