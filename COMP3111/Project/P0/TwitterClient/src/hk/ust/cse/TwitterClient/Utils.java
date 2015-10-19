package hk.ust.cse.TwitterClient;

import java.awt.geom.RoundRectangle2D;
import java.lang.reflect.Method;
import java.net.MalformedURLException;
import java.net.URL;

import org.eclipse.jface.resource.ImageDescriptor;
import org.eclipse.swt.SWT;
import org.eclipse.swt.events.KeyEvent;
import org.eclipse.swt.events.KeyListener;
import org.eclipse.swt.events.MouseEvent;
import org.eclipse.swt.events.MouseListener;
import org.eclipse.swt.graphics.Color;
import org.eclipse.swt.graphics.Image;
import org.eclipse.swt.graphics.ImageData;
import org.eclipse.swt.graphics.RGB;
import org.eclipse.swt.graphics.Rectangle;
import org.eclipse.swt.graphics.Region;
import org.eclipse.swt.graphics.Resource;
import org.eclipse.swt.widgets.Composite;
import org.eclipse.swt.widgets.Control;
import org.eclipse.swt.widgets.Text;
import org.eclipse.swt.widgets.Widget;

public class Utils {
  
  public static Image loadImageFromUrl(String url) {
    Image image = null;
    try {
      ImageDescriptor imageDesc = ImageDescriptor.createFromURL(new URL(url));
      image = imageDesc.createImage();
    } catch (MalformedURLException e) {}
    return image;
  }
  
  public static Image loadImageFromLocal(Class<?> clazz, String fileName) {
    ImageDescriptor imageDesc = ImageDescriptor.createFromFile(clazz, fileName);
    Image image = imageDesc.createImage();
    return image;
  }
  
  public static Image loadImageFromUrlAndScale(String url, int scaleWidth, int scaleHeight) {
    Image scaled = null;
    Image image = Utils.loadImageFromUrl(url);
    if (image != null) {
      if (image.getBounds().width == scaleWidth && 
          image.getBounds().height == scaleHeight) {
        scaled = image;
      }
      else {
        scaled = new Image(null, image.getImageData().scaledTo(scaleWidth, scaleHeight));
        image.dispose();
      }
    }
    return scaled;
  }
  
  public static String selectImageVersion(String imageUrl, int desiredWidth, int desiredHeight) {
    if (imageUrl.endsWith("_normal.png") || imageUrl.endsWith("_bigger.png")) {
      String suffix = null;
      if (desiredWidth <= 48 && desiredHeight <= 48) {
        suffix = "_normal.png";
      }
      else if (desiredWidth <= 73 && desiredHeight <= 73) {
        suffix = "_bigger.png";
      }
      else {
        suffix = ".png";
      }
      imageUrl = imageUrl.substring(0, imageUrl.lastIndexOf('_')) + suffix;
    }
    return imageUrl;
  }
  
  public static Color getColorFromString(String color) {
    return new Color(null, 
        Integer.valueOf(color.substring(0, 2), 16),
        Integer.valueOf(color.substring(2, 4), 16),
        Integer.valueOf(color.substring(4, 6), 16));
  }
  
  public static boolean isNullOrEmpty(String str) {
    return str == null || str.length() == 0;
  }
  
  public static void dispose(Resource res) {
    if (res != null) {
      res.dispose();
    }
  }
  
  public static void dispose(Widget control) {
    if (control != null) {
      control.dispose();
    }
  }
  
  public static void cutRoundCorner(Control control, 
      boolean upLeft, boolean upRight, boolean downLeft, boolean downRight) {
    
    Region newRegion = new Region();
    newRegion.add(0, 0, control.getBounds().width, control.getBounds().height);
    
    if (upLeft) {
      Region subtract = computeSubtractRegion(0, control.getBounds());
      newRegion.subtract(subtract);
    }
    if (upRight) {
      Region subtract = computeSubtractRegion(1, control.getBounds());
      newRegion.subtract(subtract);
    }
    if (downLeft) {
      Region subtract = computeSubtractRegion(2, control.getBounds());
      newRegion.subtract(subtract);
    }
    if (downRight) {
      Region subtract = computeSubtractRegion(3, control.getBounds());
      newRegion.subtract(subtract);
    }
    control.setRegion(newRegion);
  }
  
  private static Region computeSubtractRegion(int corner, Rectangle origRect) {
    int width  = origRect.width;
    int height = origRect.height;
    int radius = (int) (width * 0.05);
    radius = radius > 20 ? 20 : radius < 10 ? 10 : radius;
    RoundRectangle2D roundedRectangle = new RoundRectangle2D.Double(0, 0, width, height, radius, radius);
    
    Region region = new Region();
    for (int x = 0; x < radius; x++) {
      for (int y = 0; y < radius; y++) {
        if (!roundedRectangle.contains(x, y)) {
          switch (corner) {
          case 0:
            region.add(new Rectangle(x, y, 1, 1));
            break;
          case 1:
            region.add(new Rectangle(width - x, y, 1, 1));
            break;
          case 2:
            region.add(new Rectangle(x, height - y, 1, 1));
            break;
          case 3:
            region.add(new Rectangle(width - x, height - y, 1, 1));
            break;
          }
        }
      }
    }
    return region;
  }
  
  public static Image darkGradually(Image image, int startFrom) {
    Image darked = null;

    ImageData srcData = image.getImageData();
    if (srcData.depth == 24) {
      float darkRatio = 1f;
      int totalPixel = srcData.width * srcData.height;
      float[] HSBData = new float[totalPixel * 3];
      for (int i = 0; i < totalPixel; i++) {
        int x = i % srcData.width;
        int y = i / srcData.width;

        RGB rbg = srcData.palette.getRGB(srcData.getPixel(x, y));
        float[] data = java.awt.Color.RGBtoHSB(rbg.red, rbg.green, rbg.blue, null);
        HSBData[i * 3]     = data[0];
        HSBData[i * 3 + 1] = data[1];
        HSBData[i * 3 + 2] = data[2];
        
        if (y >= startFrom) {
          if (x == 0) {
            darkRatio -= (0.5 / (image.getBounds().height - startFrom));
          }
          HSBData[i * 3 + 2] *= darkRatio;
        }
      }
      
      byte[] newRGBData = new byte[totalPixel * 3];
      for (int i = 0; i < HSBData.length; i += 3) {
        int rgb = java.awt.Color.HSBtoRGB(HSBData[i], HSBData[i + 1], HSBData[i + 2]);
        newRGBData[i]     = (byte) (rgb & 0x0000FF);
        newRGBData[i + 1] = (byte) ((rgb & 0x00FFFF) >> 8);
        newRGBData[i + 2] = (byte) ((rgb & 0xFFFFFF) >> 16);
      }
      
      ImageData newImageData = new ImageData(srcData.width, srcData.height,
          srcData.depth, srcData.palette, srcData.bytesPerLine, newRGBData);
      darked = new Image(null, newImageData);
    }
    else {
      darked = new Image(null, srcData);
    }
    return darked;
  }
  
  public static void addClickListener(Control control, final String methodName, final Object callee) {
    control.addMouseListener(new MouseListener() {
      @Override
      public void mouseUp(MouseEvent arg0) {
      }
      
      @Override
      public void mouseDown(MouseEvent arg0) {
        try {
          Method method = callee.getClass().getMethod(methodName, MouseEvent.class);
          method.invoke(callee, arg0);
        } catch (Exception e) {e.printStackTrace();}
      }
      
      @Override
      public void mouseDoubleClick(MouseEvent arg0) { 
      }
    });
    
    if (control instanceof Composite) {
      for (Control child : ((Composite) control).getChildren()) {
        if (child.getListeners(SWT.MouseDown).length == 0) { // only one listen is allowed
          addClickListener(child, methodName, callee);
        }
      }
    }
  }
  
  public static void addEnterListener(Text text, final String methodName, final Object callee) {
    text.addKeyListener(new KeyListener() {
      @Override
      public void keyReleased(KeyEvent arg0) {
        if (arg0.keyCode == '\r') {
          try {
            Method method = callee.getClass().getMethod(methodName, KeyEvent.class);
            method.invoke(callee, arg0);
          } catch (Exception e) {e.printStackTrace();}
        }
      }
      
      @Override
      public void keyPressed(KeyEvent arg0) { 
      }
    });
  }
}
