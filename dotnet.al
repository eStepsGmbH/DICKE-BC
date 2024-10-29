dotnet
{
    assembly("System.Windows.Forms")
    {
        Version = '4.0.0.0';
        Culture = 'neutral';
        PublicKeyToken = 'b77a5c561934e089';

        type("System.Windows.Forms.FolderBrowserDialog"; "FolderBrowserDialog")
        {
        }

        type("System.Windows.Forms.DialogResult"; "DialogResult")
        {
        }
    }

    assembly("mscorlib")
    {
        Version = '4.0.0.0';
        Culture = 'neutral';
        PublicKeyToken = 'b77a5c561934e089';

        type("System.IO.DirectoryInfo"; "DirectoryInfo")
        {
        }

        type("System.IO.FileInfo"; "FileInfo")
        {
        }

        type("System.Array"; "Array")
        {
        }

        type("System.Text.StringBuilder"; "StringBuilder")
        {
        }

        type("System.String"; "String")
        {
        }

        type("System.DateTime"; "DateTime")
        {
        }

        type("System.IO.StreamWriter"; "StreamWriter")
        {
        }

        type("System.Text.Encoding"; "Encoding")
        {
        }

        type("System.IO.StreamReader"; "StreamReader")
        {
        }

        type("System.IO.File"; "File")
        {
        }

        type("System.IO.Stream"; "Stream")
        {
        }
    }

    assembly("ForNav.Reports.5.4.0.1997")
    {
        Version = '5.4.0.1997';
        Culture = 'neutral';
        PublicKeyToken = '5284c1af2984feb0';

        type("ForNav.Report"; "Report")
        {
        }
    }

}
