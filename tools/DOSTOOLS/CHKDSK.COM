�x
MSX-DOS CHKDSK program
Version 1.00
Copyright (c) 1986 IS Systems Ltd.
Copyright (c) 1987 ASCII Corporation

1[�C�JͦͿͶ�'͌�y�a�/�~��͝��<:&��!U	͔��<:&��͝�*\�"�*_�"�*g& �"�*a& �"�*h�"*b& �"#*j�"*\:{�(G)�9�"O*l++�"�> ���Ô>>�x͑�G ͘�* "2���!� ^ #r͘W !� ͳ� �a8�0	<W#~�: 1#ͳ�/ #~#�� !O	�#(#��~�_�޷ z2){2&��!r͔>��<~#� (��	(�+�:)_͘<�=2^�Sl�n�f"\�n�f	"_�~
2a�n& "b�~2g�n�f"h�n�f"j:^�0�x2{��!�͔�<*l)�!�"*8",�[2�R8!b͔>��<�[_  ��Kl**�uW�u�����w#�uw#x� ����x� ; ��g�A(#��*,".*2"0"4!��"|��� ~� �(�������� �ݾ�w�F��T���~�_( :}�>(!(�F��(�>��6 ��F��'��f(���(���>��6 �F*46 ��æ  ��^�Vz�(ZͰ !#�~ �����S6͓��z(�=��!'��5�x�� *4#6 #6 �6 �6 �F>��[6Ͱ6�#~�w>�����~!;�g !?�W 
!C�O !G4# 4#~�w#~�w�C8���n�f�^�Vz���( }�+ :{�	�:���= �#|� z� �[8�R�:{<G��)���6 �u�t�w�F>����n�K|�3���c�K��� 	#�~�����x(   ^#V��B��p+q�F>�..         .          �[l͓ )� ����B(����B8�!M!K4 #4Ͱ#����[l͓ #� ���Ͱ� �#�~ �n��(�Ͱ6�#~�w��[l͓ � ��o |�(�/!Q!S4 #4��[l͓ !�o(��g ���Ͱ6�#~�w�Ͱ#ˮ�/�����Ͱ �S6^#~�W����[6͓�| 
Ͱ6�#~�w�*O#"O�*Q|���>�͝���>͉*O���>�͉�>�͉���8�(4�KQ:&�G(*S	"S�CU!  "Q�[lͰ R#�~ �~��w+6 �͝!&���[l͓ 2�g(��o �|�(����(�>!͑*O�[W7�R#(��> ͤ>"͉��կ2:!4~�: 60+�!��"|��� �~�(�!͠ ��::<���!�| ����! ���> w#
6 #��,͘�%�%)))�:}�D�w#p#�*͘���Bz��E�w#p#�s#r#���͓�(��C8*Q��B"Q*Y	"Y*W#"W`i:{<G�)����6 #s#r#w�F!��M>̀*8�ͤ͝��     FILE0000CHK::��~�(���>�2:���!|� �������[_  �**�Kl~�c~�c#~�c#x� ��x����>�c���x� 
Ͳ�F ��g�A(#��!'�^�˦���V>$*4�[2��R�*4�^ $#^#V͓ �w�(���@͝>%͑���>&͑*4 "4��O͝*l++"l�!��� ~��n�f�^�Vz�(
�~#�+�(H�� F ~#�+(:~#fo> ͤ�~�� N(!&�F <�đ�|�~#fo�> ���~�đ�~��ĉ ��fhm
MSX-DOS TOOLS HELP CHKDSK
============================
The  integrity  of  the data
structures on  the  disk  is
checked.   When  errors  are
found,  corrective   actions
are taken.  If lost clusters
are  found,  a   prompt   is
issued   allowing  the  lost
disk  space  to  be   either
converted  into  usable disk
space or into files.  If the
latter is chosen, then files
of  the  form  FILE0000.CHK,
FILE0001.CHK  etc.   will be
created.

Usage: chkdsk [<drive>] [/h][/m][/f]
 /h...print this message
 /f...execute corrections
 /m...put media informations
   bytes per sector

 * first FAT sector
   sectors per FAT
   copies of FAT

 * first directory sector
   directory entries

 * first data sector
   bytes per cluster
   total clusters
 
Out of memory 
Invalid parameters 
Invalid drive name  l   '  K   /  M   0 U)    Y+W 1Q-     I+G 3 A+? 5 E+C 7 =+; 9S   ( ��[|�z(=*b�<��}�:b��Kh!��-!�4�[�:�= A:�= !:��  �[~�z�͓�~:^��2�"~PY�� 	:�G�2�<2�x2��S�2����:��  = �����++:{<)= ��Kj	���Ͱ��^#~��W!��R�0!�����ѿ�{ˇ� =�7*l�R0�=�**��*. 8;�*0�R0*2��R8+�+*|��[.!| ���S.�"��n�f"|*4"���@:}��*.��	".| ����!'�V��>̑*2"0!D"4�                ��!'�V*4 ��	��K.��B�8,"0"4�~w#�~w#�~w#�K�q#p#���� ��*4����+�� >���#����3:���2��� !%��ˎ���:%�O(.�g��̝>͑y��>͑:a�(
:go& ���!%���ѯ2%�*���R(�O��S���͘�:)=o&/͘�!��*���R(�O�S�!��:���2��:��G�ˇ2�!&�F���� �O(�� �[�x2%���͘�:)=o&0�͘��:%�G(4�O(�`��̝>͑y��>͑��ː:go& �:a� ��X��(����2%�                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                   ��͘G� Ԥ͝��(�(���(�(�7<��������!'�N�� �n !&�F 
>͑>	͑�����@͝��!'�f��̝*4��N###^#V#�|�(:'�W 	�M>\ͤ��� >��Y � Ĥx� 
� (>.ͤ�ͤ��>
đ�����O:{�(G�)����?���_ y���!�8
�!� !���͔���.5K K   K ��  & o������  "Y�S[2]���!9Y~= >02] �o0��^:](>02]��Ĥ~=#### ����ɀ�� @B �� '  �  d   
           �����#����������#�����!&�F 
- $%(<��~��#ͤ�>ͤ>
���_͘�����I !%�F(�V˖ ��>ɯ��Yy Nn !����G~#� ����  
*** Wrong version of MSX-DOS
 
*** Fatal internal error
 Error reading FAT  Error writing FAT  .
 Memory shortage, cannot store path names.
 
Errors found but /F option not given.
 Disk will not be corrected.
  (unknown path)    Invalid sub-directory converted to file.
    Invalid sub-directory would be converted to file.
    Invalid sub-directory corrected.
    Invalid sub-directory would be corrected.
    Volume name in sub-directory deleted.
    Volume name in sub-directory would be deleted.
    Duplicate volume name deleted.
    Duplicate volume name would be deleted.
    First cluster number is invalid, entry truncated.
    First cluster number is invalid, entry would be truncated.
    Contains invalid cluster, entry truncated.
    Contains invalid cluster, entry would be truncated.
    Allocation error, file size adjusted.
    Allocation error, file size would be adjusted.
  lost cluster found in   lost clusters found in   chain.
  chains.
 Convert lost chain to a file (Y/N)?  Convert lost chains to files (Y/N)?   recovered, size   would be recovered, size  Root directory full, cannot recover remaining  file.
 files.
 
Cross linked files exist.
    Is cross linked at cluster  .
  total disk space
  available disk space
  disk space freed
  disk space would be freed
  in   would be in   still in lost clusters
  would still be in lost clusters
 in bad clusters
 in reserved clusters
  recovered file
  recovered files
  user file
  user files
  system file
  system files
  hidden file
  hidden files
  directory
  directories
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                    ������� �������                                                                                    