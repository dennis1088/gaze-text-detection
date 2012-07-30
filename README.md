#Gaze Text Detection

This purpose of this project is to explore the possibility of using eye gaza data in order to supplement optical character recognition.  I will be implementing the [stroke width transform](http://research.microsoft.com/pubs/149305/1509.pdf) (SWT), which is used for natural text detection.

The idea would be to use gaze data in order to augment the text detection.  Implementing a method to [detect when a user is reading](http://www.lucs.lu.se/LUCS/144/LUCS.144.pdf) will allow us to preform the SWT on a perticular video frame and on a specific region of interest, dramatically increasing the effeciency of the text recognition.

I will be using the [Tesseract OCR engine](http://tesseract-ocr.googlecode.com/svn-history/r367/trunk/doc/tesseracticdar2007.pdf) for text recognition.

## Folder Structure

gaze