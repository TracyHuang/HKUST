package hk.ust.cse.TwitterClient;

import hk.ust.cse.TwitterClient.Controls.TwitterControl;
import hk.ust.cse.TwitterClient.Views.WholePage;

import java.io.FileInputStream;
import java.util.Properties;

import org.eclipse.swt.SWT;
import org.eclipse.swt.custom.ScrolledComposite;
import org.eclipse.swt.events.ShellEvent;
import org.eclipse.swt.events.ShellListener;
import org.eclipse.swt.graphics.Rectangle;
import org.eclipse.swt.layout.FillLayout;
import org.eclipse.swt.widgets.Composite;
import org.eclipse.swt.widgets.Display;
import org.eclipse.swt.widgets.Shell;

import twitter4j.AsyncTwitterFactory;
import twitter4j.TwitterException;
import twitter4j.TwitterFactory;

public class TwitterClient {

  public TwitterClient(final int width, final int height) throws TwitterException {
    // create Display and Shell objects
    Display display = new Display();
    final Shell shell = new Shell(display);
    
    // set layout, FillLayout is necessary for ScrollComposite
    shell.setLayout(new FillLayout());
    shell.setSize(width, height);
    shell.addShellListener(new ShellListener() {
      @Override
      public void shellIconified(ShellEvent arg0) {
      }
      
      @Override
      public void shellDeiconified(ShellEvent arg0) {
      }
      
      @Override
      public void shellDeactivated(ShellEvent arg0) {
      }
      
      @Override
      public void shellClosed(ShellEvent arg0) {
      }
      
      @Override
      public void shellActivated(ShellEvent arg0) {
        int vscrollWidth = shell.getBounds().width - shell.getClientArea().width;
        shell.setSize(width + vscrollWidth + 18, height);
      }
    });
    
    // center the initial window
    Rectangle full = display.getPrimaryMonitor().getBounds();
    Rectangle rect = shell.getBounds();
    shell.setLocation(full.x + (full.width - rect.width) / 2, 0);
    
    // set window title
    shell.setText("COMP3111 Project: Twitter Client");

    // a wrapper around twitter library
    TwitterControl.setupTwitter(TwitterFactory.getSingleton(), AsyncTwitterFactory.getSingleton());
    
    // necessary to make the window scrollable
    ScrolledComposite scrollContainer = new ScrolledComposite(shell, SWT.H_SCROLL | SWT.V_SCROLL);
    scrollContainer.getVerticalBar().setIncrement(10);
    
    // create the whole window
    m_wholeWindow = new WholePage(scrollContainer, width, height);
    scrollContainer.setContent(m_wholeWindow);

    shell.open();
    while (!shell.isDisposed()) {
      if (!display.readAndDispatch()) {
        display.sleep();  
      }
    }
    display.dispose();
  }

  public static void main(String[] args) throws TwitterException {
    checkSWTLibrary();
    checkTwitterOAuth();
    new TwitterClient(1200, 700);
  }
  
  private static void checkSWTLibrary() {
    boolean passed = true;
    try {
      Display display = new Display();
      display.dispose();
    } catch (Throwable e) {
      passed = false;
    }
    
    if (!passed) {
      String libraryName = null;
      String osName = System.getProperty("os.name").toLowerCase();
      String osArch = System.getProperty("os.arch");
      if (osName.contains("windows")) {
        libraryName = "swt-4.2.1-win32-win32-x86_64.jar";
        if (osArch.equals("x86")) {
          libraryName = "swt-4.2.1-win32-win32-x86.jar";
        }
      }
      else if (osName.contains("mac")) {
        libraryName = "swt-4.2.1-cocoa-macosx-x86_64.jar";
        if (osArch.equals("x86")) {
          libraryName = "swt-4.2.1-cocoa-macosx.jar";
        }
      }
      else {
        libraryName = "swt-4.2.1-gtk-linux-x86_64.jar";
        if (osArch.equals("x86")) {
          libraryName = "swt-4.2.1-gtk-linux-x86.jar";
        }
      }
      String path = "./lib/" + libraryName;
      
      System.err.println("Wrong SWT library for your platform, please " +
      		"configure your project build path to use SWT library: " + path);
      System.exit(-1);
    }
  }

  private static void checkTwitterOAuth() {
    String consumerKey = null;
    try {
      // load properties file
      Properties properties = new Properties();
      properties.load(new FileInputStream("twitter4j.properties"));
      consumerKey = properties.getProperty("oauth.consumerKey");
    } catch (Exception e) {}
    
    if (consumerKey == null || consumerKey.equals("your_own_consumer_key_here")) {
      System.err.println("No oauth keys found in twitter4j.properties file. " +
      		"Please obtain these keys from Twitter following the instructions in " +
      		"https://course.cse.ust.hk/comp3111/projects/P0H/P0H-Sign_Twitter.pdf, " +
      		"and put the obtained keys into twitter4j.properties file.");
      System.exit(-1);
    }
  }
  
  private final Composite m_wholeWindow;
}
