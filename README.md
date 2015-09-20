# LatexMyNotes
iOS app that converts pictures taken to latex PDF. 

Built during MHacks 2015.
Sends the picture using a post request to the server to process.
Server uses Google Tesseract that lifts the text from the picture.
The text is then converted into a Latex file which is then displayed 
as a PDF in our web app for easy readability.

Technology used: iOS(swift), Flask(python) for server, js for front-end, tesseract for OCR, MongoDB for queries


