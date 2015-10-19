package hk.ust.cse.TwitterClient.Resources;

import hk.ust.cse.TwitterClient.Utils;

import org.eclipse.swt.SWT;
import org.eclipse.swt.graphics.Color;
import org.eclipse.swt.graphics.Cursor;
import org.eclipse.swt.graphics.Font;
import org.eclipse.swt.graphics.Image;

public class Resources {

  static {
    FONT7          = new Font(null, "Arial", 7, SWT.NORMAL);
    FONT8          = new Font(null, "Arial", 8, SWT.NORMAL);
    FONT9          = new Font(null, "Arial", 9, SWT.NORMAL);
    FONT10         = new Font(null, "Arial", 10, SWT.NORMAL);
    FONT11         = new Font(null, "Arial", 11, SWT.NORMAL);
    FONT11I        = new Font(null, "Arial", 11, SWT.ITALIC);
    FONT11B        = new Font(null, "Arial", 11, SWT.BOLD);
    FONT12         = new Font(null, "Arial", 12, SWT.NORMAL);
    FONT12B        = new Font(null, "Arial", 12, SWT.BOLD);
    FONT14         = new Font(null, "Arial", 14, SWT.NORMAL);
    FONT14B        = new Font(null, "Arial", 14, SWT.BOLD);
    FONT18B        = new Font(null, "Arial", 18, SWT.BOLD);
    
    TEXT_COLOR     = new Color(null, 51, 51, 51);
    GRAY_COLOR     = new Color(null, 153, 153, 153);
    WHITE_COLOR    = new Color(null, 255, 255, 255);
    HOVER_COLOR    = new Color(null, 245, 245, 245);
    SPLIT_COLOR    = new Color(null, 232, 232, 232);
    LINK_COLOR     = new Color(null, 37, 116, 173);
    CONTROL_BAR_COLOR = new Color(null, 49, 49, 49);
    MINI_PROFILE_COLOR = new Color(null, 249, 249, 249);
    
    HAND_CURSOR    = new Cursor(null, SWT.CURSOR_HAND);
    
    VERIFIED_IMG     = Utils.loadImageFromLocal(Resources.class, "./twitter_verified_account.png");
    GO_IMG           = Utils.loadImageFromLocal(Resources.class, "./go.png");
    GO_CLICKED_IMG   = Utils.loadImageFromLocal(Resources.class, "./go_clicked.png");
    BACK_IMG         = Utils.loadImageFromLocal(Resources.class, "./back.png");
    BACK_CLICKED_IMG = Utils.loadImageFromLocal(Resources.class, "./back_clicked.png");
    HOME_IMG         = Utils.loadImageFromLocal(Resources.class, "./home.png");
    HOME_HOVER_IMG   = Utils.loadImageFromLocal(Resources.class, "./home2.png");
    ME_IMG           = Utils.loadImageFromLocal(Resources.class, "./me.png");
    ME_HOVER_IMG     = Utils.loadImageFromLocal(Resources.class, "./me2.png");
    PEOPLE_IMG       = Utils.loadImageFromLocal(Resources.class, "./people1.png");
    PEOPLE_HOVER_IMG = Utils.loadImageFromLocal(Resources.class, "./people2.png");
  }

  public static final Font  FONT7;
  public static final Font  FONT8;
  public static final Font  FONT9;
  public static final Font  FONT10;
  public static final Font  FONT11;
  public static final Font  FONT11B;
  public static final Font  FONT11I;
  public static final Font  FONT12;
  public static final Font  FONT12B;
  public static final Font  FONT14;
  public static final Font  FONT14B;
  public static final Font  FONT18B;
  
  public static final Color TEXT_COLOR;
  public static final Color GRAY_COLOR;
  public static final Color WHITE_COLOR;
  public static final Color HOVER_COLOR;
  public static final Color SPLIT_COLOR;
  public static final Color LINK_COLOR;
  public static final Color CONTROL_BAR_COLOR;
  public static final Color MINI_PROFILE_COLOR;
  
  public static final Cursor HAND_CURSOR;
  
  public static final Image VERIFIED_IMG;
  public static final Image GO_IMG;
  public static final Image GO_CLICKED_IMG;
  public static final Image BACK_IMG;
  public static final Image BACK_CLICKED_IMG;
  public static final Image HOME_IMG;
  public static final Image HOME_HOVER_IMG;
  public static final Image ME_IMG;
  public static final Image ME_HOVER_IMG;
  public static final Image PEOPLE_IMG;
  public static final Image PEOPLE_HOVER_IMG;
}
