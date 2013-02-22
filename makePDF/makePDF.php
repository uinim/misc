<?php
/**
 *  makePDF.php
 *
 *  @author    unknown
 *  @package   unknown
 *  @version   1.0
 */

require('lib/fpdf.php');

// ディレクトリ配列の作成
$targetDir = "data/";
$subDirs = array();
$subDirs = getFileList($targetDir);

// ディレクトリ+ファイルリストの配列を作成
$pdfList = array();
foreach ($subDirs as $subDir) {
    $fileList = array();
    $targetPath = $targetDir . $subDir;
    $fileList = getFileList($targetPath);

    array_push($pdfList, array($subDir => $fileList));
}

// 画像を回転してPDFを作成
foreach ($pdfList as $subDir) {
    foreach ($subDir as $dir => $files) {
        $files_fullpath = array();
        foreach ($files as $file) {
            $filePath = $targetDir . $dir . "/" . $file;
            // 画像の回転
            imgRotate($filePath);

            array_push($files_fullpath, $filePath);
        }

        // PDFの作成
        makePDFFromImgs($files_fullpath, $dir . ".pdf");
    }
}

// 指定ディレクトリのファイルリストを取得
function getFileList ($target) {
    $result = array();
    if ($dir = opendir($target)) {
        while (($file = readdir($dir)) !== false) {
            if (!preg_match("/^\..*/", $file)) {
                array_push($result, $file);
            }
        }

    }
    closedir($dir);

    return $result;
}

// 画像の回転
function imgRotate ($filename) {
    // 回転角度
    $degrees = 90;

    // 読み込み
    $source = imagecreatefromjpeg($filename);

    // 回転
    $rotate = imagerotate($source, $degrees, 0);

    // 出力
    //header('Content-type: image/jpeg');
    imagejpeg($rotate, $filename);
}

// 画像配列からPDFを作成
function makePDFFromImgs ($files, $output) {

    // 画像からPDFを作成
    // Portrait|Landscape
    $pdf=new FPDF('Portrait', 'mm', 'A4');

    foreach ($files as $imageFile) {
        // ページを追加
        $pdf->AddPage();

        $x = $pdf->getX();
        $y = $pdf->getY();
        $w = $pdf->w - ($pdf->lMargin + $pdf->rMargin);
        $h = $pdf->h - ($pdf->tMargin + $pdf->bMargin);

        // 画像の追加
        $pdf->Image($imageFile, $x, $y, $w, $h);
    }

    // ファイル出力
    $pdf->Output($output, 'F');
}


?>