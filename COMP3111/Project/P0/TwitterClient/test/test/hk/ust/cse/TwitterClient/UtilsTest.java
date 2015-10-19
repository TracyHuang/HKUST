package test.hk.ust.cse.TwitterClient;

import static org.junit.Assert.assertEquals;
import hk.ust.cse.TwitterClient.Utils;

import org.eclipse.swt.graphics.Color;
import org.junit.Test;

public class UtilsTest {
  @Test(timeout=10000)
  public void testGetColorFromString() throws Throwable {
    assertEquals(new Color(null, 171, 205, 239), Utils.getColorFromString("ABCDEF"));
  }
}
