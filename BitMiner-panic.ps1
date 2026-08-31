# BitMiner panic key: Ctrl+Space hides/restores the BITMINER window system-wide.
# Started hidden by BitMiner.bat; exits by itself when the game window closes.
$created=$false
$mutex=New-Object System.Threading.Mutex($true,'BitMinerPanicHotkey',[ref]$created)
if(-not $created){exit}

Add-Type -ReferencedAssemblies System.Windows.Forms,System.Drawing @'
using System;
using System.Runtime.InteropServices;
using System.Windows.Forms;
public class PanicForm : Form {
  [DllImport("user32.dll")] static extern bool RegisterHotKey(IntPtr h,int id,int mod,int vk);
  [DllImport("user32.dll")] static extern bool UnregisterHotKey(IntPtr h,int id);
  [DllImport("user32.dll")] static extern IntPtr FindWindow(string c,string t);
  [DllImport("user32.dll")] static extern bool ShowWindow(IntPtr h,int cmd);
  [DllImport("user32.dll")] static extern bool IsIconic(IntPtr h);
  [DllImport("user32.dll")] static extern bool SetForegroundWindow(IntPtr h);
  Timer watch; bool seen=false; int age=0;
  public PanicForm(){
    ShowInTaskbar=false; Opacity=0; FormBorderStyle=FormBorderStyle.None; Size=new System.Drawing.Size(1,1);
    Load+=delegate{ Hide(); RegisterHotKey(Handle,1,2,0x20); };   // MOD_CONTROL + VK_SPACE
    FormClosed+=delegate{ UnregisterHotKey(Handle,1); };
    watch=new Timer(); watch.Interval=3000;
    watch.Tick+=delegate{
      age+=3;
      IntPtr w=FindWindow(null,"BITMINER");
      if(w!=IntPtr.Zero) seen=true;
      else if(seen||age>60) Application.Exit();   // game closed (or never appeared)
    };
    watch.Start();
  }
  protected override void WndProc(ref Message m){
    if(m.Msg==0x0312){
      IntPtr w=FindWindow(null,"BITMINER");
      if(w!=IntPtr.Zero){
        if(IsIconic(w)){ ShowWindow(w,9); SetForegroundWindow(w); }  // SW_RESTORE
        else ShowWindow(w,6);                                        // SW_MINIMIZE
      }
    }
    base.WndProc(ref m);
  }
}
'@
[System.Windows.Forms.Application]::Run((New-Object PanicForm))
$mutex.ReleaseMutex()
