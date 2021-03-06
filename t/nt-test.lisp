;;;; nt-test.lisp
;; NOTE: To run this test file, execute `(asdf:test-system :ppath)' in your Lisp.
;;

(in-package :cl-user)
(defpackage ppath.test.nt-test
  (:use :cl
        :alexandria
        :ppath.test.base
        :prove)
  (:shadowing-import-from ppath.details.generic
   concat)
  (:shadowing-import-from ppath.details.nt
                          split
                          splitdrive
                          splitunc
                          isabs
                          ismount
                          abspath
                          normcase
                          basename
                          dirname
                          join
                          expanduser
                          expandvars
                          normpath
                          relpath))

(in-package :ppath.test.nt-test)

;; NOTE: To run this test file, execute `(asdf:test-system :ppath)' in your Lisp.

(plan nil)


(subtest "Test splitdrive"
  (test-input splitdrive "C:\\" '("C:" . "\\"))
  (test-input splitdrive "C:\\Sources\\lisp" '("C:" . "\\Sources\\lisp"))
  (test-input splitdrive "C:/Sources/lisp" '("C:" . "/Sources/lisp"))
  (test-input splitdrive "//host-name/share-name/dir" '("//host-name/share-name" . "/dir"))
  (test-input splitdrive "\\\\host-name\\share-name\\dir" '("\\\\host-name\\share-name" . "\\dir"))
  (test-input splitdrive "dir1\\dir2" '("" . "dir1\\dir2"))
  (test-input splitdrive "\\\\host-name\\share-name\\" '("\\\\host-name\\share-name" . "\\"))
  (test-input splitdrive "\\\\host-name\\share-name" '("\\\\host-name\\share-name" . "")))


(subtest "Test split"
  (test-input split "c:\\Sources\\lisp" '("c:\\Sources" . "lisp"))
  (test-input split "\\\\host-name\\share-name\\dir1\\dir2"
              '("\\\\host-name\\share-name\\dir1" . "dir2"))
  (test-input split "c:\\" '("c:\\" . ""))
  (test-input split "\\\\host-name\\share-name\\" '("\\\\host-name\\share-name\\" . ""))
  (test-input split "c:/" '("c:/" . ""))
  (test-input split "//host-name/share-name/" '("//host-name/share-name/" . ""))
  (test-input split "//host-name/share-name" '("//host-name/share-name" . "")))


(subtest "Test splitunc"
  (test-input splitunc "c:\\Sources\\lisp" '("" . "c:\\Sources\\lisp"))
  (test-input splitunc "c:/Sources/lisp" '("" . "c:/Sources/lisp"))
  (test-input splitunc "\\\\host-name\\share-name\\Sources\\lisp"
              '("\\\\host-name\\share-name" . "\\Sources\\lisp"))
  (test-input splitunc "//host-name/share-name/Sources/lisp"
              '("//host-name/share-name" . "/Sources/lisp"))
  (test-input splitunc "\\\\\\host-name\\share-name\\Sources\\lisp"
              '("" . "\\\\\\host-name\\share-name\\Sources\\lisp"))
  (test-input splitunc "///host-name/share-name/Sources/lisp"
              '("" . "///host-name/share-name/Sources/lisp"))
  (test-input splitunc "\\\\host-name\\\\share-name\\Sources\\lisp"
              '("" . "\\\\host-name\\\\share-name\\Sources\\lisp"))
  (test-input splitunc "//host-name//share-name/Sources/lisp"
              '("" . "//host-name//share-name/Sources/lisp"))
  (test-input splitunc "//host-name/share-name"
              '("//host-name/share-name" . ""))
  (test-input splitunc "//host-name/share-name/"
              '("//host-name/share-name" . "/")))



(subtest "Test isabs"
  (test-input isabs "c:\\" t)
  (test-input isabs "\\Sources" t)
  (test-input isabs "/Sources/lisp" t)
  (test-input isabs "\\\\host-name\\share-name\\" t)
  (test-input isabs "my/dir" nil)
  (test-input isabs "my\\dir1\dir2" nil)
  (test-input isabs "file.txt" nil))


(subtest "Test normcase"
  (test-input normcase "C:\\" "c:/"))


(subtest "Test basename"
  (test-input basename "C:\\dir\\file.txt" "file.txt"))


(subtest "Test dirname"
  (test-input dirname "C:\\dir\\file.txt" "C:\\dir"))


(subtest "Test ismount"
  (test-input ismount "C:\\dir\\file.txt" nil)
  (test-input ismount "\\\\host-name\\share-name" t)
  (test-input ismount "//host-name/share-name" t)
  (test-input ismount "//host-name/share-name/" t)
  (test-input ismount "//host-name/share-name/dir" nil)
  (test-input ismount "local-path\\dir" nil))


(subtest "Test join"
  (test-input join "" "")
  (test-input join '("" "" "") "")
  (test-input join '("a") "a")
  (test-input join '("/a") "/a")
  (test-input join '("\\a") "\\a")
  (test-input join '("a:") "a:")
  (test-input join '("a:" "\\b") "a:\\b")
  (test-input join '("a" "\\b") "\\b")
  (test-input join '("a" "b" "c") "a\\b\\c")
  (test-input join '("a\\" "b" "c") "a\\b\\c")
  (test-input join '("a" "b\\" "c") "a\\b\\c")
  (test-input join '("a" "b" "\\c") "\\c")
  (test-input join '("d:\\" "\\a") "d:\\a")
  (test-input join '("d:\\" "a" "b") "d:\\a\\b")

  (test-input join '("" "a") "a")
  (test-input join '("" "" "" "" "a") "a")
  (test-input join '("a" "") "a\\")
  (test-input join '("a" "" "" "" "") "a\\")
  (test-input join '("a\\" "") "a\\")
  (test-input join '("a\\" "" "" "" "") "a\\")
  (test-input join '("a/" "") "a/")

  (test-input join '("a/b" "x/y") "a/b\\x/y")
  (test-input join '("/a/b" "x/y") "/a/b\\x/y")
  (test-input join '("/a/b/" "x/y") "/a/b/x/y")
  (test-input join '("c:" "x/y") "c:x/y")
  (test-input join '("c:a/b" "x/y") "c:a/b\\x/y")
  (test-input join '("c:a/b/" "x/y") "c:a/b/x/y")
  (test-input join '("c:/" "x/y") "c:/x/y")
  (test-input join '("c:/a/b" "x/y") "c:/a/b\\x/y")
  (test-input join '("c:/a/b/" "x/y") "c:/a/b/x/y")
  (test-input join '("//host-name/share-name" "x/y") "//host-name/share-name\\x/y")
  (test-input join '("//host-name/share-name/" "x/y") "//host-name/share-name/x/y")
  (test-input join '("//host-name/share-name/a/b" "x/y") "//host-name/share-name/a/b\\x/y")

  (test-input join '("a/b" "/x/y") "/x/y")
  (test-input join '("/a/b" "/x/y") "/x/y")
  (test-input join '("c:" "/x/y") "c:/x/y")
  (test-input join '("c:a/b" "/x/y") "c:/x/y")
  (test-input join '("c:/" "/x/y") "c:/x/y")
  (test-input join '("c:/a/b" "/x/y") "c:/x/y")
  (test-input join '("//host-name/share-name" "/x/y") "//host-name/share-name/x/y")
  (test-input join '("//host-name/share-name/" "/x/y") "//host-name/share-name/x/y")
  (test-input join '("//host-name/share-name/a" "/x/y") "//host-name/share-name/x/y")

  (test-input join '("c:" "C:x/y") "C:x/y")
  (test-input join '("c:a/b" "C:x/y") "C:a/b\\x/y")
  (test-input join '("c:/" "C:x/y") "C:/x/y")
  (test-input join '("c:/a/b" "C:x/y") "C:/a/b\\x/y")

  (map-product (lambda (x y)
                 (is (apply #'join (list x y))
                     y
                     :test #'equal
                     (format nil "Testing combination: join (~s ~s) == ~s" x y y)))
               '("" "a/b" "/a/b" "c:" "c:a/b" "c:/" "c:/a/b")
               '("d:" "d:x/y" "d:/" "d:/x/y")))


(subtest "Test expanduser"
  ;; environment - hash table containing "mocked" environment vars
  (let ((env-vars (make-hash-table :test #'equalp)))
    ;; quickly set mocked environ variable 
    (flet ((env (x y) (setf (gethash x env-vars) y))
           (unenv (x) (remhash x env-vars)))
      ;; mock the getenv function 
      (with-mocked-function (uiop::getenv
                             (lambda (name) (gethash name env-vars)))
        (clrhash env-vars)
        (test-input expanduser "~test" "~test")
        (env "HOMEPATH" "users\\dir")
        (env "HOMEDRIVE" "C:\\")
        (test-input expanduser "~test" "C:\\users\\test")
        (test-input expanduser "~" "C:\\users\\dir")
        
        (unenv "HOMEDRIVE")
        (test-input expanduser "~test" "users\\test")
        (test-input expanduser "~" "users\\dir")

        (clrhash env-vars)
        (env "USERPROFILE" "C:\\users\\dir")
        (test-input expanduser "~test" "C:\\users\\test")
        (test-input expanduser "~" "C:\\users\\dir")

        (clrhash env-vars)
        (env "HOME" "C:\\dir\\users")
        (test-input expanduser "~test" "C:\\dir\\test")
        (test-input expanduser "~" "C:\\dir\\users")

        (test-input expanduser "~test\\foo\\bar" 
                    "C:\\dir\\test\\foo\\bar")
        (test-input expanduser "~test/foo/bar" 
                    "C:\\dir\\test/foo/bar")
        (test-input expanduser "~\\foo\\bar" 
                    "C:\\dir\\users\\foo\\bar")
        (test-input expanduser "~/foo/bar" 
                    "C:\\dir\\users/foo/bar")))))

;; TODO: move to generic test
(subtest "Test unicode"
  (test-input join '("C:\\Users\myuser" "Мои документы")
              "C:\\Users\myuser\\Мои документы")
  (test-input split "C:\\Users\myuser\\Мои документы"
              '("C:\\Users\myuser" . "Мои документы")))


(subtest "Test expandvars"
  ;; environment - hash table containing "mocked" environment vars
  (let ((env-vars (make-hash-table :test #'equalp)))
    ;; quickly set mocked environ variable 
    (flet ((env (x y) (setf (gethash x env-vars) y))
           (unenv (x) (remhash x env-vars)))
      ;; mock the getenv function 
      (with-mocked-function (ppath.details.generic::getenv
                              (lambda (name) (gethash name env-vars)))
        (clrhash env-vars)
        (env "foo" "bar")
        (env "{foo" "baz1")
        (env "{foo}" "baz2")
        (test-input expandvars "foo" "foo")
        (test-input expandvars "$foo bar" "bar bar")
        (test-input expandvars "$$foo bar" "$foo bar")
        (test-input expandvars "${foo}bar" "barbar")
        (test-input expandvars "$[foo]bar" "$[foo]bar")
        (test-input expandvars "$bar bar" "$bar bar")
        (test-input expandvars "$?bar" "$?bar")
        (test-input expandvars "$foo}bar" "bar}bar")
        (test-input expandvars "${foo" "${foo")
        (test-input expandvars "${{foo}}" "baz1}")
        (test-input expandvars "$foo$foo" "barbar")
        (test-input expandvars "$bar$bar" "$bar$bar")
        (test-input expandvars "%foo% bar" "bar bar")
        (test-input expandvars "%foo%bar" "barbar")
        (test-input expandvars "%foo%%foo%" "barbar")
        (test-input expandvars "%%foo%%foo%foo%" "%foo%foobar")
        (test-input expandvars "%?bar%" "%?bar%")
        (test-input expandvars "%foo%%bar" "bar%bar")
        (test-input expandvars "\'%foo%\'%bar" "\'%foo%\'%bar")
        (test-input expandvars "bar\'%foo%" "bar\'%foo%")
        ;; some additional degraded/corner cases
        (test-input expandvars "" "")
        (test-input expandvars "'" "'")
        (test-input expandvars "$" "$")
        (test-input expandvars "%" "%")
        (test-input expandvars "test'" "test'")
        (test-input expandvars "test''" "test''")
        (test-input expandvars "test$$" "test$")
        (test-input expandvars "test%%" "test%")))))


(subtest "Test normpath"
  (test-input normpath "A//////././//.//B" "A\\B")
  (test-input normpath "A/./B" "A\\B")
  (test-input normpath "A/foo/../B" "A\\B")
  (test-input normpath "C:A//B" "C:A\\B")
  (test-input normpath "D:A/./B" "D:A\\B")
  (test-input normpath "e:A/foo/../B" "e:A\\B")

  (test-input normpath "C:///A//B" "C:\\A\\B")
  (test-input normpath "D:///A/./B" "D:\\A\\B")
  (test-input normpath "e:///A/foo/../B" "e:\\A\\B")

  (test-input normpath ".." "..")
  (test-input normpath "." ".")
  (test-input normpath "" ".")
  (test-input normpath "/" "\\")
  (test-input normpath "c:/" "c:\\")
  (test-input normpath "/../.././.." "\\")
  (test-input normpath "c:/../../.." "c:\\")
  (test-input normpath "../.././.." "..\\..\\..")
  (test-input normpath "K:../.././.." "K:..\\..\\..")
  (test-input normpath "C:////a/b" "C:\\a\\b")
  (test-input normpath "//machine/share//a/b" "\\\\machine\\share\\a\\b")

  (test-input normpath "\\\\.\\NUL" "\\\\.\\NUL")
  (test-input normpath "\\\\?\\D:/XY\\Z" "\\\\?\\D:/XY\\Z")
  (test-input normpath "b/../a" "a")
  (test-input normpath "../b/../a" "..\\a")
  (test-input normpath "..\\a\\b" "..\\a\\b")
  (test-input normpath "../b" "..\\b"))


(subtest "Test relpath"
  (test-input relpath "a" "a")
  (let ((abs (abspath "a")))
    (test-input relpath abs "a"))
  (test-input relpath "a/b" "a\\b")
  (test-input relpath "../a/b" "..\\a\\b")

  (let* ((tmppath (join (ppath.details.generic:get-temp-path)
                        (format nil "@test_~d_tmp" (ppath.details.generic:getpid))))
         (old-dir (ppath.details.generic::getcwd))
         (currentdir (basename tmppath)))
    ;; ensure-directories-exist requires trailing slash
    (ensure-directories-exist (concat tmppath "/"))
    (chdir (concat tmppath "/"))
    (test-input relpath '("a" "../b") (concat "..\\" currentdir "\\a"))
    (test-input relpath '("a/b" "../c") (concat "..\\" currentdir "\\a\\b"))
    (chdir old-dir)
    (uiop/filesystem:delete-empty-directory (pathname tmppath)))

  (test-input relpath '("a" "b/c") "..\\..\\a")
  (test-input relpath '("//conky/mountpoint/a" "//conky/mountpoint/b/c") "..\\..\\a")
  (test-input relpath '("a" "a") ".")
  (test-input relpath '("/foo/bar/bat" "/x/y/z") "..\\..\\..\\foo\\bar\\bat")
  (test-input relpath '("/foo/bar/bat" "/foo/bar") "bat")
  (test-input relpath '("/foo/bar/bat" "/") "foo\\bar\\bat")
  (test-input relpath '("/" "/foo/bar/bat") "..\\..\\..")
  (test-input relpath '("/foo/bar/bat" "/x") "..\\foo\\bar\\bat")
  (test-input relpath '("/x" "/foo/bar/bat") "..\\..\\..\\x")
  (test-input relpath '("/" "/") ".")
  (test-input relpath '("/a" "/a") ".")
  (test-input relpath '("/a/b" "/a/b") ".")
  (test-input relpath '("c:/foo" "C:/FOO") "."))

(finalize)
