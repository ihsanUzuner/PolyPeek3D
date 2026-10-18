using System;
using System.Drawing;
using System.Diagnostics;
using System.IO;
using System.Runtime.InteropServices;
using System.Text;
using System.Text.RegularExpressions;
using System.Threading.Tasks;
using System.Windows.Forms;
using Microsoft.Web.WebView2.Core;
using Microsoft.Web.WebView2.WinForms;

namespace PolyPeek3D
{
    static class Program
    {
        [STAThread]
        static void Main(string[] args)
        {
            Application.EnableVisualStyles();
            Application.SetCompatibleTextRenderingDefault(false);
            Application.ThreadException += (s, e) => Log.Write("ERROR", "UI exception: " + e.Exception);
            AppDomain.CurrentDomain.UnhandledException += (s, e) => Log.Write("ERROR", "Unhandled exception: " + e.ExceptionObject);
            Application.Run(new MainForm(args.Length > 0 ? args[0] : null));
        }
    }

    // Always-on log: %LOCALAPPDATA%\PolyPeek3D\log.txt (about 1 MB, then it is moved to log.old.txt). Stays on this PC, nothing is sent anywhere.
    // Only file NAMES and sizes are written, never full paths.
    static class Log
    {
        static readonly object Gate = new object();
        public static readonly string Dir = Path.Combine(
            Environment.GetFolderPath(Environment.SpecialFolder.LocalApplicationData), "PolyPeek3D");
        public static readonly string FilePath = Path.Combine(Dir, "log.txt");
        const long MaxBytes = 1024 * 1024;
        static readonly int Pid = Process.GetCurrentProcess().Id;

        public static void Write(string level, string msg)
        {
            try
            {
                lock (Gate)
                {
                    Directory.CreateDirectory(Dir);
                    var fi = new FileInfo(FilePath);
                    if (fi.Exists && fi.Length > MaxBytes)
                    {
                        string old = Path.Combine(Dir, "log.old.txt");
                        if (File.Exists(old)) File.Delete(old);
                        File.Move(FilePath, old);
                    }
                    string line = DateTime.Now.ToString("yyyy-MM-dd HH:mm:ss.fff") + " [" + Pid + "] [" + level + "] "
                        + Scrub(msg ?? "").Replace("\r", " ").Replace("\n", " ");
                    // FileShare.ReadWrite: several PolyPeek3D windows may write at the same time
                    using (var fs = new FileStream(FilePath, FileMode.Append, FileAccess.Write, FileShare.ReadWrite))
                    using (var w = new StreamWriter(fs, new UTF8Encoding(false)))
                        w.WriteLine(line);
                }
            }
            catch { } // logging must never break the app
        }

        // Error texts (exceptions, stack traces) can contain full paths such as C:\Users\name\Desktop\model.fbx:
        // the folder part is removed so only the file name stays ("model.fbx").
        static readonly Regex PathDirs = new Regex(@"(?:(?<![A-Za-z0-9])[A-Za-z]:|\\\\[^\\\s]+)\\(?:[^\\/:*?""<>|\r\n]+\\)*", RegexOptions.Compiled);
        static string Scrub(string s) { try { return PathDirs.Replace(s, ""); } catch { return s; } }

        [StructLayout(LayoutKind.Sequential, CharSet = CharSet.Auto)]
        class MEMORYSTATUSEX
        {
            public uint dwLength = (uint)Marshal.SizeOf(typeof(MEMORYSTATUSEX));
            public uint dwMemoryLoad;
            public ulong ullTotalPhys, ullAvailPhys, ullTotalPageFile, ullAvailPageFile, ullTotalVirtual, ullAvailVirtual, ullAvailExtendedVirtual;
        }
        [DllImport("kernel32.dll", SetLastError = true)]
        static extern bool GlobalMemoryStatusEx([In, Out] MEMORYSTATUSEX s);

        public static string MemInfo()
        {
            try
            {
                var m = new MEMORYSTATUSEX();
                if (!GlobalMemoryStatusEx(m)) return "";
                return "RAM " + (m.ullAvailPhys / 1048576) + " MB free of " + (m.ullTotalPhys / 1048576) + " MB";
            }
            catch { return ""; }
        }
    }

    class MainForm : Form
    {
        // folder that holds viewer.html and the js files (next to the exe)
        static readonly string WebDir = AppDomain.CurrentDomain.BaseDirectory;
        // Virtual addresses: there is no real server, WebView2 maps these hosts straight to folders.
        // NOTE: do not use a ".local" suffix, Windows tries to resolve it on the network and waits ~2 s.
        const string Host = "https://polypeek3d.example/";       // viewer.html + js files
        const string ModelHostName = "polypeek3dmodel.example";
        const string ModelHost = "https://" + ModelHostName + "/";   // folder of the opened model (textures, .mtl, .bin are read from here)

        readonly string modelPath;
        readonly WebView2 wv;

        public MainForm(string file)
        {
            // full path: a relative one ("PolyPeek3D model.glb" from a command prompt) has no folder part to map as the model host
            modelPath = (!string.IsNullOrEmpty(file) && File.Exists(file)) ? Path.GetFullPath(file) : null;

            Text = (modelPath != null ? Path.GetFileName(modelPath) + " - " : "") + AppTitle;
            try { Icon = Icon.ExtractAssociatedIcon(Application.ExecutablePath); } catch { }
            ClientSize = new Size(1280, 760);
            StartPosition = FormStartPosition.CenterScreen;
            RestoreWindow();
            FormClosing += (s, e) => { SaveWindow(); Log.Write("INFO", "exit"); };
            BackColor = Color.FromArgb(43, 43, 43); // avoid a white flash while the page loads

            wv = new WebView2
            {
                Dock = DockStyle.Fill,
                DefaultBackgroundColor = Color.FromArgb(43, 43, 43)
            };
            Controls.Add(wv);

            Load += async (s, e) => await InitAsync();
        }

        // Window position / size / maximized state: %LOCALAPPDATA%\PolyPeek3D\window.txt
        static readonly string StatePath = Path.Combine(
            Environment.GetFolderPath(Environment.SpecialFolder.LocalApplicationData),
            "PolyPeek3D", "window.txt");

        void RestoreWindow()
        {
            try
            {
                if (!File.Exists(StatePath)) return;
                string[] p = File.ReadAllText(StatePath).Trim().Split(',');
                if (p.Length < 5) return;
                var r = new Rectangle(int.Parse(p[0]), int.Parse(p[1]), int.Parse(p[2]), int.Parse(p[3]));
                if (r.Width < 400 || r.Height < 300) return;
                // If the saved position is no longer on any screen (monitor unplugged), fall back to the default
                bool visible = false;
                foreach (var sc in Screen.AllScreens)
                {
                    var i = Rectangle.Intersect(sc.WorkingArea, r);
                    if (i.Width >= 100 && i.Height >= 50) { visible = true; break; }
                }
                if (!visible) return;
                StartPosition = FormStartPosition.Manual;
                Bounds = r;
                if (p[4] == "1") WindowState = FormWindowState.Maximized;
            }
            catch { }
        }

        void SaveWindow()
        {
            try
            {
                var r = WindowState == FormWindowState.Normal ? Bounds : RestoreBounds;
                Directory.CreateDirectory(Path.GetDirectoryName(StatePath));
                File.WriteAllText(StatePath, string.Join(",", r.X, r.Y, r.Width, r.Height,
                    WindowState == FormWindowState.Maximized ? "1" : "0"));
            }
            catch { }
        }

        // Window title: "PolyPeek3D v3.2.0". The version comes from the VERSION file (built into the exe by PolyPeek3D.csproj).
        // The build time is written only to the log (the version number alone does not tell two builds apart).
        static readonly string AppVersion = Application.ProductVersion.Split('+')[0];
        static readonly string AppTitle = "PolyPeek3D v" + AppVersion;
        static string BuildStamp()
        {
            try { return " (build " + File.GetLastWriteTime(Application.ExecutablePath).ToString("yyyy-MM-dd HH:mm") + ")"; }
            catch { return ""; }
        }

        // What the page last told us: the file being opened and the stage it reached. Used to explain a crash.
        string lastFile = "", lastInfo = "";
        long lastSize;
        int crashes;
        DateTime lastCrash = DateTime.MinValue;

        void OnWebMessage(object sender, CoreWebView2WebMessageReceivedEventArgs e)
        {
            string m;
            try { m = e.TryGetWebMessageAsString(); } catch { return; }
            if (string.IsNullOrEmpty(m)) return;
            int i = m.IndexOf('|');
            string lv = i > 0 ? m.Substring(0, i) : "INFO";
            string body = i > 0 ? m.Substring(i + 1) : m;
            if (lv == "CMD")
            {
                if (body == "OPENLOG") OpenLog();
                else if (body == "DEVTOOLS") { try { wv.CoreWebView2.OpenDevToolsWindow(); } catch { } } // F12 / Ctrl+Shift+I (the browser's own shortcut is off)
                return;
            }
            if (lv == "DROP") { OnDrop(body, e); return; }
            if (lv == "OPEN")
            {
                int k = body.LastIndexOf('|');
                lastFile = k > 0 ? body.Substring(0, k) : body;
                long.TryParse(k > 0 ? body.Substring(k + 1) : "0", out lastSize);
                return;
            }
            if (lv == "INFO") lastInfo = body;
            Log.Write(lv, body);
        }

        // A file dropped onto the window (or picked with the folder button): the page cannot see where it lives, so it hands the file
        // object over. The page gets an address for the file's folder back, and textures, .mtl and .bin next to the model are then found
        // without dropping them too.
        // The files are served by OnDropResource below: a folder mapping (as used for a double-clicked model) only takes effect for pages
        // loaded after it was set, and the page must not be reloaded here.
        // Every drop gets a host name of its own (m1.., m2..): a file with the same name in another folder must not come from the cache.
        int dropSeq;
        string dropHost, dropDir;

        void OnDrop(string id, CoreWebView2WebMessageReceivedEventArgs e)
        {
            string url = "";
            try
            {
                var objs = e.AdditionalObjects;
                var f = (objs != null && objs.Count > 0) ? objs[0] as CoreWebView2File : null;
                string dir = (f != null && !string.IsNullOrEmpty(f.Path)) ? Path.GetDirectoryName(Path.GetFullPath(f.Path)) : null;
                if (!string.IsNullOrEmpty(dir) && Directory.Exists(dir))
                {
                    dropDir = dir.EndsWith("\\") ? dir : dir + "\\";
                    dropHost = "m" + (++dropSeq) + "." + ModelHostName;
                    url = "https://" + dropHost + "/";
                }
            }
            catch (Exception ex) { Log.Write("WARN", "dropped file: its folder could not be used: " + ex.Message); }
            try { wv.CoreWebView2.PostWebMessageAsString("FOLDER|" + id + "|" + url); } catch { } // empty address: the page uses only the dropped files
        }

        const string DropHeaders = "Access-Control-Allow-Origin: *\nCache-Control: no-store"; // the page lives on another (virtual) host

        static string MimeOf(string path)
        {
            switch (Path.GetExtension(path).ToLowerInvariant())
            {
                case ".png": return "image/png";
                case ".jpg": case ".jpeg": return "image/jpeg";
                case ".webp": return "image/webp";
                case ".gif": return "image/gif";
                case ".bmp": return "image/bmp";
                case ".svg": return "image/svg+xml";
                case ".gltf": case ".json": return "application/json";
                case ".mtl": return "text/plain";
                default: return "application/octet-stream";
            }
        }

        // Serves the files of the dropped model's folder (and its subfolders, nothing outside it) to the page.
        void OnDropResource(object sender, CoreWebView2WebResourceRequestedEventArgs e)
        {
            var env = wv.CoreWebView2.Environment;
            try
            {
                var u = new Uri(e.Request.Uri);
                if (dropDir != null && string.Equals(u.Host, dropHost, StringComparison.OrdinalIgnoreCase))
                {
                    string rel = Uri.UnescapeDataString(u.AbsolutePath).TrimStart('/').Replace('/', '\\');
                    string full = Path.GetFullPath(Path.Combine(dropDir, rel));
                    if (full.StartsWith(dropDir, StringComparison.OrdinalIgnoreCase) && File.Exists(full))
                    {
                        var fs = new FileStream(full, FileMode.Open, FileAccess.Read, FileShare.ReadWrite | FileShare.Delete);
                        e.Response = env.CreateWebResourceResponse(fs, 200, "OK", DropHeaders + "\nContent-Type: " + MimeOf(full));
                        return;
                    }
                }
            }
            catch (Exception ex) { Log.Write("WARN", "dropped model: a file next to it could not be read: " + ex.Message); }
            e.Response = env.CreateWebResourceResponse(null, 404, "Not Found", DropHeaders);
        }

        void OnProcessFailed(object sender, CoreWebView2ProcessFailedEventArgs e)
        {
            string reason = "", exit = "";
            try { reason = e.Reason.ToString(); exit = e.ExitCode.ToString(); } catch { }
            Log.Write("ERROR", "WebView2 process failed: kind=" + e.ProcessFailedKind + " reason=" + reason + " exit=" + exit
                + " | file=" + lastFile + " (" + (lastSize / 1048576) + " MB) | last step: " + lastInfo + " | " + Log.MemInfo());

            if (e.ProcessFailedKind == CoreWebView2ProcessFailedKind.BrowserProcessExited)
            {
                MessageBox.Show("The WebView2 browser process stopped.\nDetails are in the log: " + Log.FilePath,
                    "PolyPeek3D", MessageBoxButtons.OK, MessageBoxIcon.Error);
                Close();
                return;
            }
            if (e.ProcessFailedKind != CoreWebView2ProcessFailedKind.RenderProcessExited) return; // GPU / utility / unresponsive: only logged

            // Do not leave Chromium's own "page has a problem" screen (its Refresh button would load the same huge file again):
            // restart the viewer without a file and let it show our own message.
            DateTime now = DateTime.Now;
            crashes = (now - lastCrash).TotalSeconds < 10 ? crashes + 1 : 1;
            lastCrash = now;
            if (crashes > 3)
            {
                MessageBox.Show("The viewer keeps stopping. Details are in the log: " + Log.FilePath,
                    "PolyPeek3D", MessageBoxButtons.OK, MessageBoxIcon.Error);
                return;
            }
            string url = Host + "viewer.html?crash=1&reason=" + Uri.EscapeDataString(reason)
                + "&name=" + Uri.EscapeDataString(lastFile) + "&size=" + lastSize;
            lastFile = ""; lastInfo = ""; lastSize = 0;
            BeginInvoke(new Action(() => { try { wv.CoreWebView2.Navigate(url); } catch (Exception ex) { Log.Write("ERROR", "restart after crash failed: " + ex.Message); } }));
        }

        void OpenLog()
        {
            try
            {
                if (File.Exists(Log.FilePath)) Process.Start("explorer.exe", "/select,\"" + Log.FilePath + "\"");
                else Process.Start("explorer.exe", "\"" + Log.Dir + "\"");
            }
            catch { }
        }

        async Task InitAsync()
        {
            try
            {
                string os = ""; try { os = RuntimeInformation.OSDescription; } catch { }
                Log.Write("INFO", "start " + AppTitle + BuildStamp() + " | " + os + " | " + (Environment.Is64BitProcess ? "x64" : "x86")
                    + " | " + Log.MemInfo() + (modelPath != null ? " | opened with: " + Path.GetFileName(modelPath) : ""));
                // No extensions are loaded; it uses its own data folder
                string data = Path.Combine(
                    Environment.GetFolderPath(Environment.SpecialFolder.LocalApplicationData),
                    "PolyPeek3D", "WebView2");
                var env = await CoreWebView2Environment.CreateAsync(null, data);
                await wv.EnsureCoreWebView2Async(env);
                Log.Write("INFO", "WebView2 runtime " + env.BrowserVersionString);
            }
            catch (Exception ex)
            {
                Log.Write("ERROR", "WebView2 could not start: " + ex.Message);
                MessageBox.Show(
                    "WebView2 Runtime could not be started.\n\nFix: install the \"Evergreen Bootstrapper\" from " +
                    "https://go.microsoft.com/fwlink/p/?LinkId=2124703 and try again.\n\nDetails: " + ex.Message,
                    "PolyPeek3D", MessageBoxButtons.OK, MessageBoxIcon.Error);
                Close();
                return;
            }

            var core = wv.CoreWebView2;
            core.Settings.AreDefaultContextMenusEnabled = false; // right click is used for panning
            core.Settings.IsStatusBarEnabled = false;
            core.Settings.IsZoomControlEnabled = false;          // Ctrl+wheel must not zoom the page
            // Browser shortcuts off: F5 / Ctrl+R (reload: a dropped model is lost), Alt+Left/Right (back / forward), Ctrl+P (print),
            // Ctrl+S (save page), Ctrl+F / F3 (find). This also turns off F12; the page asks for the console itself (CMD|DEVTOOLS).
            core.Settings.AreBrowserAcceleratorKeysEnabled = false;

            // Stay on our own virtual address (dropping a file must not navigate away). The model given on the command line is opened
            // only by the very first navigation: going back after a crash (mouse back button...) must not load the same file again.
            bool firstNav = true;
            core.NavigationStarting += (s, e) =>
            {
                bool ok = e.Uri.StartsWith(Host, StringComparison.OrdinalIgnoreCase)
                    && (firstNav || e.Uri.IndexOf("file=", StringComparison.OrdinalIgnoreCase) < 0);
                if (!ok) { e.Cancel = true; return; }
                firstNav = false;
            };
            // Window title follows the model shown in the page (it also changes when a file is dropped onto the window)
            core.DocumentTitleChanged += (s, e) =>
            {
                string t = core.DocumentTitle ?? "";
                if (t.IndexOf(".example/", StringComparison.OrdinalIgnoreCase) >= 0) return; // the page URL while it is still loading
                Text = (t.Length == 0 || t == "PolyPeek3D") ? AppTitle : t + " - " + AppTitle;
            };
            core.NewWindowRequested += (s, e) => e.Handled = true;
            core.WebMessageReceived += OnWebMessage;   // log lines + commands from the page
            core.ProcessFailed += OnProcessFailed;     // the page's renderer process died (for example out of memory)
            core.AddWebResourceRequestedFilter("https://*." + ModelHostName + "/*", CoreWebView2WebResourceContext.All);
            core.WebResourceRequested += OnDropResource; // files next to a dropped model

            // WebView2's own (local, fast) file serving
            core.SetVirtualHostNameToFolderMapping("polypeek3d.example", WebDir, CoreWebView2HostResourceAccessKind.Allow);
            if (modelPath != null)
                core.SetVirtualHostNameToFolderMapping(ModelHostName, Path.GetDirectoryName(modelPath), CoreWebView2HostResourceAccessKind.Allow);

            string url = Host + "viewer.html";
            if (modelPath != null)
            {
                string fileName = Path.GetFileName(modelPath);
                url += "?file=" + Uri.EscapeDataString(ModelHost + Uri.EscapeDataString(fileName))
                     + "&name=" + Uri.EscapeDataString(fileName);
            }
            core.Navigate(url);
        }
    }
}
