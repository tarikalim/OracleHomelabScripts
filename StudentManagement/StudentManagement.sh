#!/bin/bash

# Kullanıcıdan giriş bilgilerini al
read -p "T.C. Kimlik Numaranızı giriniz: " tc
read -sp "Şifrenizi giriniz: " password
echo

# Kullanıcıyı doğrula
user_info=$(grep "^$tc," users.txt)

if [ -z "$user_info" ]; then
    echo "Kullanıcı bulunamadı."
    exit 1
fi

# Kullanıcının şifresini doğrula
stored_password=$(echo "$user_info" | cut -d ',' -f4)

if [ "$stored_password" == "$password" ]; then
    echo "Giriş başarılı!"
    # Kullanıcının rolünü al
    user_role=$(echo "$user_info" | cut -d ',' -f5)
    echo "Rolünüz: $user_role"
else
    echo "Hatalı şifre."
    exit 1
fi

# Ana menüye dönmek için bekleme fonksiyonu
wait_for_keypress() {
    read -n 1 -s -r -p "Ana menüye dönmek için herhangi bir tuşa basın..."
    echo
}

# Admin işlemleri
admin_menu() {
    while true; do
        echo "1) Öğrenci Ekle"
        echo "2) Tüm Öğrencileri Görüntüle"
        echo "3) Öğrenci Bilgilerini Görüntüle"
        echo "4) Öğrenci Bilgilerini Güncelle"
        echo "5) Öğrenciyi Sil"
        echo "6) Çıkış"
        read -p "Bir seçenek giriniz: " choice

        case $choice in
            1)
                read -p "TC: " new_tc
                read -p "Ad: " new_name
                read -p "Soyad: " new_surname
                read -sp "Şifre: " new_password
                echo
                echo "$new_tc,$new_name,$new_surname,$new_password,normal" >> users.txt
                echo "Öğrenci başarıyla eklendi."
                wait_for_keypress
                ;;
            2)
                echo "Tüm öğrenciler:"
                cat users.txt
                wait_for_keypress
                ;;
            3)
                read -p "TC'sini girdiğiniz öğrencinin bilgilerini görüntüleyin: " search_tc
                student_info=$(grep "^$search_tc," users.txt)
                if [ -z "$student_info" ]; then
                    echo "Öğrenci bulunamadı."
                else
                    echo "Öğrenci bilgileri: $student_info"
                fi
                wait_for_keypress
                ;;
            4)
                read -p "Güncellemek istediğiniz öğrencinin TC'sini giriniz: " update_tc
                student_info=$(grep "^$update_tc," users.txt)
                if [ -z "$student_info" ]; then
                    echo "Öğrenci bulunamadı."
                else
                    read -p "Yeni ad: " new_name
                    read -p "Yeni soyad: " new_surname
                    read -sp "Yeni şifre: " new_password
                    echo
                    sed -i "/^$update_tc,/c\\$update_tc,$new_name,$new_surname,$new_password,normal" users.txt
                    echo "Öğrenci bilgileri güncellendi."
                fi
                wait_for_keypress
                ;;
            5)
                read -p "Silmek istediğiniz öğrencinin TC'sini giriniz: " delete_tc
                sed -i "/^$delete_tc,/d" users.txt
                echo "Öğrenci silindi."
                wait_for_keypress
                ;;
            6)
                echo "Çıkış yapılıyor..."
                exit 0
                ;;
            *)
                echo "Geçersiz seçenek."
                wait_for_keypress
                ;;
        esac
    done
}

# Normal kullanıcı işlemleri
normal_menu() {
    echo "Kullanıcı bilgileri:"
    echo "$user_info"
    echo "Çıkış yapılıyor..."
    exit 0
}

# Rolüne göre menüyü göster
if [ "$user_role" == "admin" ]; then
    admin_menu
else
    normal_menu
fi
