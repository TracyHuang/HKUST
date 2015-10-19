package test.hk.ust.cse.TwitterClient.Views;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertNotNull;
import hk.ust.cse.TwitterClient.Views.ControlBar;

import org.eclipse.swt.widgets.Display;
import org.eclipse.swt.widgets.Shell;
import org.junit.Test;

public class ControlBarTest {
  @Test(timeout=10000)
  public void testConstructor() throws Throwable {
    Display display = new Display();
    Shell shell = new Shell(display);
    ControlBar ctrlBar = new ControlBar(shell, 10, 10, 0, null, null, null);
    assertNotNull(ctrlBar);
    assertEquals(10, ctrlBar.getBounds().width);
    assertEquals(10, ctrlBar.getBounds().height);
    shell.dispose();
    display.dispose();
  }
}
