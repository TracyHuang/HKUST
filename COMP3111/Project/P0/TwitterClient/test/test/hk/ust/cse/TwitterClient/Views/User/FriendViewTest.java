package test.hk.ust.cse.TwitterClient.Views.User;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertNotNull;
import static org.junit.Assert.assertTrue;
import hk.ust.cse.TwitterClient.Views.User.FriendView;

import org.eclipse.swt.widgets.Display;
import org.eclipse.swt.widgets.Shell;
import org.junit.Test;

import test.hk.ust.cse.TwitterClient.Mocks.MockUser;

public class FriendViewTest {
  @Test(timeout=10000)
  public void testConstructor() throws Throwable {
    Display display = new Display();
    Shell shell = new Shell(display);
    
    MockUser friend = new MockUser("FakeUser", "FakeScreenName", true, "Fake Description");
    FriendView friendView = new FriendView(shell, friend, 10, null, null);
    assertNotNull(friendView);
    assertEquals("FakeUser", friendView.getFriend().getName());
    assertEquals("FakeScreenName", friendView.getFriend().getScreenName());
    assertEquals("Fake Description", friendView.getFriend().getDescription());
    assertTrue(friendView.getFriend().isVerified());
    
    shell.dispose();
    display.dispose();
  }

}
