import { supabase } from "@/lib/supabase";

interface Visitor {
  id: string;
  full_name: string;
  phone: string;
  id_card_front: string;
  id_card_back: string;
  checked_in_at: string | null;
  checked_out_at: string | null;
  gate_pass_id: string;
  gate_pass: {
    pass_number: string;
    department: string;
    contact_person: string;
    purpose: string;
    status: string;
  };
}

async function getVisitors() {
  console.log('Đang lấy danh sách visitors...');
  const { data: visitors, error } = await supabase
    .from('visitors')
    .select(`
      id,
      full_name,
      phone,
      id_card_front,
      id_card_back,
      checked_in_at,
      checked_out_at,
      gate_pass_id,
      gate_pass:gate_passes!gate_pass_id(
        pass_number,
        department,
        contact_person,
        purpose,
        status
      )
    `)
    .order('created_at', { ascending: false });

  if (error) {
    console.error('Lỗi khi lấy dữ liệu:', error);
    throw error;
  }
  
  console.log('Dữ liệu nhận được:', visitors);
  
  // Chuyển đổi dữ liệu để phù hợp với interface
  const formattedVisitors = visitors?.map(visitor => ({
    ...visitor,
    gate_pass: Array.isArray(visitor.gate_pass) ? visitor.gate_pass[0] : visitor.gate_pass
  })) || [];

  return formattedVisitors as Visitor[];
}

export default async function VisitorsPage() {
  const visitors = await getVisitors();

  return (
    <div>
      <div className="mb-8">
        <h2 className="text-2xl font-bold text-gray-900">Danh sách khách</h2>
        <p className="mt-1 text-sm text-gray-500">
          Tất cả khách đã đăng ký vào cổng
        </p>
      </div>

      <div className="mt-4 overflow-hidden shadow ring-1 ring-black ring-opacity-5 sm:rounded-lg">
        <table className="min-w-full divide-y divide-gray-300">
          <thead className="bg-gray-50">
            <tr>
              <th scope="col" className="py-3.5 pl-4 pr-3 text-left text-sm font-semibold text-gray-900 sm:pl-6">
                Họ tên
              </th>
              <th scope="col" className="px-3 py-3.5 text-left text-sm font-semibold text-gray-900">
                Số điện thoại
              </th>
              <th scope="col" className="px-3 py-3.5 text-left text-sm font-semibold text-gray-900">
                Số phiếu
              </th>
              <th scope="col" className="px-3 py-3.5 text-left text-sm font-semibold text-gray-900">
                Phòng ban
              </th>
              <th scope="col" className="px-3 py-3.5 text-left text-sm font-semibold text-gray-900">
                Mục đích
              </th>
              <th scope="col" className="px-3 py-3.5 text-left text-sm font-semibold text-gray-900">
                Trạng thái
              </th>
              <th scope="col" className="px-3 py-3.5 text-left text-sm font-semibold text-gray-900">
                Check-in
              </th>
              <th scope="col" className="px-3 py-3.5 text-left text-sm font-semibold text-gray-900">
                Check-out
              </th>
            </tr>
          </thead>
          <tbody className="divide-y divide-gray-200 bg-white">
            {visitors.map((visitor) => (
              <tr key={visitor.id}>
                <td className="whitespace-nowrap py-4 pl-4 pr-3 text-sm font-medium text-gray-900 sm:pl-6">
                  {visitor.full_name}
                </td>
                <td className="whitespace-nowrap px-3 py-4 text-sm text-gray-500">
                  {visitor.phone}
                </td>
                <td className="whitespace-nowrap px-3 py-4 text-sm text-gray-500">
                  {visitor.gate_pass.pass_number}
                </td>
                <td className="whitespace-nowrap px-3 py-4 text-sm text-gray-500">
                  {visitor.gate_pass.department}
                </td>
                <td className="whitespace-nowrap px-3 py-4 text-sm text-gray-500">
                  {visitor.gate_pass.purpose}
                </td>
                <td className="whitespace-nowrap px-3 py-4 text-sm text-gray-500">
                  <span className={`inline-flex rounded-full px-2 text-xs font-semibold leading-5 ${
                    visitor.gate_pass.status === 'created' ? 'bg-yellow-100 text-yellow-800' :
                    visitor.gate_pass.status === 'approved' ? 'bg-blue-100 text-blue-800' :
                    visitor.gate_pass.status === 'checked_in' ? 'bg-green-100 text-green-800' :
                    'bg-gray-100 text-gray-800'
                  }`}>
                    {visitor.gate_pass.status === 'created' ? 'Chờ duyệt' :
                     visitor.gate_pass.status === 'approved' ? 'Đã duyệt' :
                     visitor.gate_pass.status === 'checked_in' ? 'Đang trong công ty' :
                     'Đã ra về'}
                  </span>
                </td>
                <td className="whitespace-nowrap px-3 py-4 text-sm text-gray-500">
                  {visitor.checked_in_at ? new Date(visitor.checked_in_at).toLocaleString('vi-VN') : '-'}
                </td>
                <td className="whitespace-nowrap px-3 py-4 text-sm text-gray-500">
                  {visitor.checked_out_at ? new Date(visitor.checked_out_at).toLocaleString('vi-VN') : '-'}
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>
    </div>
  );
} 